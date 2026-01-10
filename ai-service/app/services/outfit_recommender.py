"""
Outfit Recommender - Generates outfit recommendations from user's wardrobe
"""

import logging
from typing import Dict, Any, List, Optional
from openai import AsyncOpenAI
from app.config import settings
from app.services.embedding_service import EmbeddingService

logger = logging.getLogger(__name__)


class OutfitRecommender:
    def __init__(self):
        self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.embedding_service = EmbeddingService()
        self.system_prompt = """You are an expert personal stylist creating outfit recommendations.
Your role is to suggest complete, cohesive outfits from a user's existing wardrobe.

Focus on:
- Color harmony
- Formality alignment with occasion
- Season appropriateness
- Style consistency
- Practical wearability

Always be encouraging and explain your choices clearly."""

    async def recommend(
        self,
        user_id: str,
        context: Dict[str, Any],
        analysis: Optional[Dict[str, Any]] = None
    ) -> List[Dict[str, Any]]:
        """
        Generate outfit recommendations based on context and user's wardrobe

        Args:
            user_id: User ID to fetch wardrobe from
            context: Occasion, vibe, weather, etc.
            analysis: Optional existing outfit analysis for swap suggestions

        Returns:
            List of outfit recommendations
        """
        try:
            # Build search queries for different categories
            occasion = context.get("occasion", "casual")
            vibe = context.get("vibe", "smart casual")
            formality_desc = self._get_formality_description(context)

            # Search for suitable items in each category
            tops = await self.embedding_service.search_similar(
                query_text=f"{formality_desc} {vibe} top for {occasion}",
                user_id=user_id,
                category="top",
                limit=10
            )

            bottoms = await self.embedding_service.search_similar(
                query_text=f"{formality_desc} {vibe} bottom for {occasion}",
                user_id=user_id,
                category="bottom",
                limit=10
            )

            shoes = await self.embedding_service.search_similar(
                query_text=f"{formality_desc} {vibe} shoes for {occasion}",
                user_id=user_id,
                category="shoes",
                limit=10
            )

            outerwear = await self.embedding_service.search_similar(
                query_text=f"{formality_desc} {vibe} outerwear for {occasion}",
                user_id=user_id,
                category="outerwear",
                limit=5
            )

            # Generate outfit combinations using LLM
            recommendations = await self._generate_combinations(
                tops=tops,
                bottoms=bottoms,
                shoes=shoes,
                outerwear=outerwear,
                context=context,
                analysis=analysis
            )

            return recommendations

        except Exception as e:
            logger.error(f"Error generating recommendations: {e}")
            # Return empty list on error
            return []

    async def _generate_combinations(
        self,
        tops: List[Dict],
        bottoms: List[Dict],
        shoes: List[Dict],
        outerwear: List[Dict],
        context: Dict[str, Any],
        analysis: Optional[Dict[str, Any]]
    ) -> List[Dict[str, Any]]:
        """Use LLM to score and rank outfit combinations"""

        # Build prompt with available items
        prompt = self._build_combination_prompt(
            tops, bottoms, shoes, outerwear, context, analysis
        )

        try:
            response = await self.openai_client.chat.completions.create(
                model="gpt-4-turbo-preview",
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {"role": "user", "content": prompt}
                ],
                response_format={"type": "json_object"},
                max_tokens=2000,
                temperature=0.8,
            )

            import json
            result = json.loads(response.choices[0].message.content)

            return result.get("recommendations", [])

        except Exception as e:
            logger.error(f"Error generating combinations: {e}")
            return []

    def _build_combination_prompt(
        self,
        tops: List[Dict],
        bottoms: List[Dict],
        shoes: List[Dict],
        outerwear: List[Dict],
        context: Dict[str, Any],
        analysis: Optional[Dict[str, Any]]
    ) -> str:
        """Build a prompt for the LLM to generate outfit combinations"""

        prompt = f"""Create 3 complete outfit recommendations for the following context:

Context:
- Occasion: {context.get('occasion', 'casual')}
- Vibe: {context.get('vibe', 'smart casual')}
- Location: {context.get('location', '')}
- Who with: {context.get('whoWith', '')}
- Notes: {context.get('notes', '')}

Available items from user's wardrobe:

TOPS:
"""
        for i, item in enumerate(tops[:5], 1):
            meta = item.get("metadata", {})
            prompt += f"{i}. {meta.get('description', meta.get('sub_category', 'top'))} (ID: {item.get('wardrobe_item_id')})\n"

        prompt += "\nBOTTOMS:\n"
        for i, item in enumerate(bottoms[:5], 1):
            meta = item.get("metadata", {})
            prompt += f"{i}. {meta.get('description', meta.get('sub_category', 'bottom'))} (ID: {item.get('wardrobe_item_id')})\n"

        prompt += "\nSHOES:\n"
        for i, item in enumerate(shoes[:5], 1):
            meta = item.get("metadata", {})
            prompt += f"{i}. {meta.get('description', meta.get('sub_category', 'shoes'))} (ID: {item.get('wardrobe_item_id')})\n"

        if outerwear:
            prompt += "\nOUTERWEAR (optional):\n"
            for i, item in enumerate(outerwear[:3], 1):
                meta = item.get("metadata", {})
                prompt += f"{i}. {meta.get('description', meta.get('sub_category', 'outerwear'))} (ID: {item.get('wardrobe_item_id')})\n"

        prompt += """
Create 3 complete outfit recommendations. For each:
1. Select items that work well together (color, formality, style)
2. Explain why this combination works
3. Rate confidence (0-1)

Respond in this JSON format:
{
  "recommendations": [
    {
      "type": "full_outfit",
      "items": ["item_id_1", "item_id_2", "item_id_3"],
      "explanation": "This combination works because...",
      "confidence": 0.85,
      "rank": 0,
      "style_notes": "Clean, modern, appropriate for the occasion"
    }
  ]
}

Ensure variety in the recommendations - don't reuse the same items across all 3."""

        return prompt

    def _get_formality_description(self, context: Dict[str, Any]) -> str:
        """Map context to formality description"""
        occasion = context.get("occasion", "").lower()
        vibe = context.get("vibe", "").lower()

        if "wedding" in occasion or "formal" in occasion or "gala" in occasion:
            return "very formal"
        elif "work" in occasion or "business" in occasion or "interview" in occasion:
            return "formal business"
        elif "dinner" in occasion or "date" in occasion:
            return "smart casual"
        elif "casual" in vibe or "relaxed" in vibe:
            return "casual comfortable"
        else:
            return "smart casual"

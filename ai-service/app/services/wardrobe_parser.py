"""
Wardrobe Item Parser - Extracts metadata from wardrobe item photos
"""

import logging
from typing import Dict, Any, List
from openai import AsyncOpenAI
from app.config import settings

logger = logging.getLogger(__name__)


class WardrobeParser:
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.system_prompt = """You are an expert fashion merchandiser and clothing categorization specialist.
Your role is to analyze photos of individual clothing items and extract detailed metadata.

Be precise and consistent with categorization. Always output valid JSON matching the specified schema."""

    async def parse(self, image_url: str, user_id: str = None) -> Dict[str, Any]:
        """
        Parse a wardrobe item photo and extract structured metadata

        Args:
            image_url: URL of the clothing item photo
            user_id: Optional user ID for context

        Returns:
            Dict with category, colors, style tags, formality, etc.
        """
        try:
            user_prompt = """Analyze this clothing item photo and extract detailed metadata.

Provide your analysis in the following JSON format:
{
  "category": "outerwear",
  "sub_category": "blazer",
  "colors": ["navy"],
  "pattern": "solid",
  "material": "wool",
  "formality": 8,
  "season_tags": ["autumn", "winter", "spring"],
  "style_tags": ["smart", "classic", "minimal", "business"],
  "fit_style": "regular",
  "description": "Navy wool blazer with notch lapels"
}

Categories: top, bottom, outerwear, dress, shoes, bag, accessory
Sub-categories (examples):
  - top: t-shirt, shirt, blouse, sweater, hoodie, tank
  - bottom: jeans, trousers, skirt, shorts, leggings
  - outerwear: blazer, coat, jacket, cardigan
  - shoes: sneakers, boots, loafers, heels, sandals
  - bag: backpack, tote, crossbody, clutch
  - accessory: watch, belt, scarf, hat, sunglasses

Formality: 0-10 scale (0=loungewear, 5=smart casual, 10=black tie)
Season tags: spring, summer, autumn, winter, all-season
Fit style: slim, regular, relaxed, oversized

Be specific and consistent."""

            response = await self.client.chat.completions.create(
                model=settings.OPENAI_MODEL,
                messages=[
                    {"role": "system", "content": self.system_prompt},
                    {
                        "role": "user",
                        "content": [
                            {"type": "text", "text": user_prompt},
                            {
                                "type": "image_url",
                                "image_url": {"url": image_url, "detail": "high"}
                            }
                        ]
                    }
                ],
                response_format={"type": "json_object"},
                max_tokens=800,
                temperature=0.3,  # Lower temperature for more consistent categorization
            )

            # Parse the response
            import json
            result = json.loads(response.choices[0].message.content)

            # Generate vector ID placeholder (will be replaced by actual embedding)
            vector_id = f"vec_{user_id}_{result.get('category', 'item')}"

            return {
                "category": result.get("category", "top"),
                "sub_category": result.get("sub_category", ""),
                "colors": result.get("colors", []),
                "pattern": result.get("pattern"),
                "material": result.get("material"),
                "formality": result.get("formality", 5),
                "season_tags": result.get("season_tags", []),
                "style_tags": result.get("style_tags", []),
                "fit_style": result.get("fit_style"),
                "description": result.get("description", ""),
                "vector_id": vector_id
            }

        except Exception as e:
            logger.error(f"Error parsing wardrobe item: {str(e)}")
            raise

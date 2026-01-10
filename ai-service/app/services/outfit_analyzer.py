"""
Outfit Analysis Service - Uses GPT-4 Vision to analyze outfit photos
"""

import logging
from typing import Dict, Any, List
from openai import AsyncOpenAI
from app.config import settings

logger = logging.getLogger(__name__)


class OutfitAnalyzer:
    def __init__(self):
        self.client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
        self.system_prompt = """You are an expert fashion stylist and outfit consultant.
Your role is to analyze outfit photos and provide constructive, non-judgmental feedback.

Focus on:
- Fit and proportions
- Color harmony and cohesion
- Appropriateness for the given context
- Style consistency
- Garment identification

Never make comments about:
- Body shape or size
- Attractiveness
- Personal worth

Always be encouraging and educational. Output your analysis as valid JSON."""

    async def analyze(self, image_url: str, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze an outfit photo and return structured feedback

        Args:
            image_url: URL of the outfit photo
            context: Dict with occasion, vibe, location, etc.

        Returns:
            Dict with garments_detected, style_signals, and risks
        """
        try:
            # Build the prompt with context
            user_prompt = self._build_prompt(context)

            # Call GPT-4 Vision
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
                max_tokens=1500,
                temperature=0.7,
            )

            # Parse the response
            result = response.choices[0].message.content
            import json
            parsed_result = json.loads(result)

            # Ensure proper structure
            return {
                "garments_detected": parsed_result.get("garments_detected", []),
                "style_signals": parsed_result.get("style_signals", {}),
                "risks": parsed_result.get("risks", []),
                "overall_score": parsed_result.get("overall_score", 7.0),
                "summary": parsed_result.get("summary", ""),
                "positives": parsed_result.get("positives", []),
                "issues": parsed_result.get("issues", []),
                "suggestions": parsed_result.get("suggestions", [])
            }

        except Exception as e:
            logger.error(f"Error analyzing outfit: {str(e)}")
            raise

    def _build_prompt(self, context: Dict[str, Any]) -> str:
        """Build a detailed prompt based on context"""
        occasion = context.get("occasion", "casual outing")
        vibe = context.get("vibe", "smart casual")
        who_with = context.get("whoWith", "")
        notes = context.get("notes", "")

        prompt = f"""Analyze this outfit photo and provide detailed feedback.

Context:
- Occasion: {occasion}
- Desired vibe: {vibe}
"""

        if who_with:
            prompt += f"- Who with: {who_with}\n"
        if notes:
            prompt += f"- Additional notes: {notes}\n"

        prompt += """
Please provide your analysis in the following JSON format:
{
  "garments_detected": [
    {"type": "top", "desc": "white button-down shirt", "color": ["white"], "pattern": "solid", "fit": "regular"},
    {"type": "bottom", "desc": "dark navy trousers", "color": ["navy"], "pattern": "solid"},
    {"type": "shoes", "desc": "brown leather loafers", "color": ["brown"]}
  ],
  "style_signals": {
    "formality": 7.5,
    "cohesion": 8.0,
    "contrast": 6.5,
    "season_fit": "spring/fall",
    "silhouette": "balanced",
    "notes": ["clean palette", "classic styling"]
  },
  "risks": [
    {"issue": "Potentially too formal for a casual setting", "confidence": 0.6}
  ],
  "overall_score": 7.8,
  "summary": "Clean, classic smart-casual outfit. The neutral palette is cohesive and the proportions are balanced.",
  "positives": [
    {"title": "Color harmony", "detail": "Neutral tones create a sophisticated, easy-to-wear palette."},
    {"title": "Fit", "detail": "Well-proportioned silhouette with balanced top and bottom."}
  ],
  "issues": [
    {"title": "Context mismatch", "detail": "May be slightly overdressed for a very casual occasion."}
  ],
  "suggestions": [
    {"type": "swap", "target": "shoes", "instruction": "For more casual: swap to white sneakers"},
    {"type": "add", "target": "accessory", "instruction": "Consider a simple watch to complete the look"}
  ]
}

Focus on actionable, constructive feedback."""

        return prompt

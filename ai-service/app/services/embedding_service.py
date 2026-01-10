"""
Embedding Service - Generates and stores vector embeddings using CLIP and text embeddings
"""

import logging
from typing import List, Dict, Any, Optional
import httpx
from openai import AsyncOpenAI
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from app.config import settings
import uuid

logger = logging.getLogger(__name__)


class EmbeddingService:
    def __init__(self):
        self.openai_client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)

        # Initialize Qdrant client
        try:
            self.qdrant_client = QdrantClient(
                url=settings.QDRANT_URL,
                api_key=settings.QDRANT_API_KEY,
            )
            self._ensure_collection()
        except Exception as e:
            logger.warning(f"Could not connect to Qdrant: {e}")
            self.qdrant_client = None

    def _ensure_collection(self):
        """Ensure the wardrobe items collection exists"""
        if not self.qdrant_client:
            return

        try:
            collections = self.qdrant_client.get_collections().collections
            collection_names = [c.name for c in collections]

            if settings.QDRANT_COLLECTION_NAME not in collection_names:
                self.qdrant_client.create_collection(
                    collection_name=settings.QDRANT_COLLECTION_NAME,
                    vectors_config=VectorParams(
                        size=1536,  # text-embedding-3-large dimension
                        distance=Distance.COSINE
                    )
                )
                logger.info(f"Created Qdrant collection: {settings.QDRANT_COLLECTION_NAME}")
        except Exception as e:
            logger.error(f"Error ensuring collection: {e}")

    async def generate_text_embedding(self, text: str) -> List[float]:
        """Generate embedding from text using OpenAI"""
        try:
            response = await self.openai_client.embeddings.create(
                model=settings.OPENAI_EMBEDDING_MODEL,
                input=text
            )
            return response.data[0].embedding
        except Exception as e:
            logger.error(f"Error generating text embedding: {e}")
            raise

    async def generate_and_store(
        self,
        wardrobe_item_id: str,
        image_url: str,
        metadata: Dict[str, Any],
        user_id: str
    ) -> str:
        """
        Generate embedding for a wardrobe item and store in Qdrant

        Args:
            wardrobe_item_id: UUID of the wardrobe item
            image_url: URL of the item photo
            metadata: Parsed metadata (category, colors, tags, etc.)
            user_id: User ID for filtering

        Returns:
            vector_id: ID of the stored vector in Qdrant
        """
        try:
            # Build text representation for embedding
            text = self._build_text_representation(metadata)

            # Generate embedding
            embedding = await self.generate_text_embedding(text)

            # Store in Qdrant
            if self.qdrant_client:
                vector_id = str(uuid.uuid4())

                point = PointStruct(
                    id=vector_id,
                    vector=embedding,
                    payload={
                        "wardrobe_item_id": wardrobe_item_id,
                        "user_id": user_id,
                        "category": metadata.get("category"),
                        "sub_category": metadata.get("sub_category"),
                        "colors": metadata.get("colors", []),
                        "formality": metadata.get("formality", 5),
                        "season_tags": metadata.get("season_tags", []),
                        "style_tags": metadata.get("style_tags", []),
                        "description": metadata.get("description", ""),
                    }
                )

                self.qdrant_client.upsert(
                    collection_name=settings.QDRANT_COLLECTION_NAME,
                    points=[point]
                )

                logger.info(f"Stored embedding for item {wardrobe_item_id} with vector_id {vector_id}")
                return vector_id
            else:
                # Return a placeholder if Qdrant is not available
                return f"placeholder_{wardrobe_item_id}"

        except Exception as e:
            logger.error(f"Error generating and storing embedding: {e}")
            raise

    def _build_text_representation(self, metadata: Dict[str, Any]) -> str:
        """Build a text string from metadata for embedding generation"""
        parts = []

        category = metadata.get("category", "")
        sub_category = metadata.get("sub_category", "")
        colors = metadata.get("colors", [])
        pattern = metadata.get("pattern", "")
        material = metadata.get("material", "")
        style_tags = metadata.get("style_tags", [])
        season_tags = metadata.get("season_tags", [])
        formality = metadata.get("formality", 5)

        if sub_category:
            parts.append(sub_category)
        elif category:
            parts.append(category)

        if colors:
            parts.append(" ".join(colors))

        if pattern:
            parts.append(pattern)

        if material:
            parts.append(material)

        # Formality description
        if formality <= 2:
            parts.append("very casual")
        elif formality <= 4:
            parts.append("casual")
        elif formality <= 6:
            parts.append("smart casual")
        elif formality <= 8:
            parts.append("formal")
        else:
            parts.append("very formal")

        if style_tags:
            parts.extend(style_tags)

        if season_tags:
            parts.extend(season_tags)

        return " ".join(parts)

    async def search_similar(
        self,
        query_text: str,
        user_id: str,
        category: Optional[str] = None,
        limit: int = 30
    ) -> List[Dict[str, Any]]:
        """Search for similar wardrobe items"""
        if not self.qdrant_client:
            return []

        try:
            # Generate embedding for query
            query_embedding = await self.generate_text_embedding(query_text)

            # Build filter
            filter_conditions = {"must": [{"key": "user_id", "match": {"value": user_id}}]}

            if category:
                filter_conditions["must"].append({
                    "key": "category",
                    "match": {"value": category}
                })

            # Search
            results = self.qdrant_client.search(
                collection_name=settings.QDRANT_COLLECTION_NAME,
                query_vector=query_embedding,
                query_filter=filter_conditions,
                limit=limit
            )

            return [
                {
                    "wardrobe_item_id": hit.payload["wardrobe_item_id"],
                    "score": hit.score,
                    "metadata": hit.payload
                }
                for hit in results
            ]

        except Exception as e:
            logger.error(f"Error searching similar items: {e}")
            return []

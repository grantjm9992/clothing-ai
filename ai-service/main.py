"""
AI Service for Clothing AI - Outfit Analysis and Wardrobe Intelligence
"""

from fastapi import FastAPI, HTTPException, File, UploadFile, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import uvicorn
from pathlib import Path
import logging

from app.services.outfit_analyzer import OutfitAnalyzer
from app.services.wardrobe_parser import WardrobeParser
from app.services.embedding_service import EmbeddingService
from app.services.outfit_recommender import OutfitRecommender
from app.config import settings

# Configure logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Clothing AI - AI Service",
    description="AI-powered outfit analysis and wardrobe intelligence",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
outfit_analyzer = OutfitAnalyzer()
wardrobe_parser = WardrobeParser()
embedding_service = EmbeddingService()
outfit_recommender = OutfitRecommender()


# Request/Response models
class OutfitAnalysisRequest(BaseModel):
    image_url: str
    context: Dict[str, Any] = Field(default_factory=dict)


class OutfitAnalysisResponse(BaseModel):
    garments_detected: List[Dict[str, Any]]
    style_signals: Dict[str, Any]
    risks: List[Dict[str, Any]]


class WardrobeItemRequest(BaseModel):
    image_url: str


class WardrobeItemResponse(BaseModel):
    category: str
    sub_category: str
    colors: List[str]
    pattern: Optional[str] = None
    material: Optional[str] = None
    formality: int
    season_tags: List[str]
    style_tags: List[str]


class EmbeddingRequest(BaseModel):
    image_url: Optional[str] = None
    text: Optional[str] = None
    wardrobe_item_id: str


class EmbeddingResponse(BaseModel):
    embedding: List[float]
    dimension: int


class OutfitRecommendationRequest(BaseModel):
    user_id: str
    context: Dict[str, Any]
    outfit_signals: Optional[Dict[str, Any]] = None
    limit: int = 3


class OutfitRecommendationResponse(BaseModel):
    recommendations: List[Dict[str, Any]]
    feedback: Dict[str, Any]


# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-service",
        "version": "1.0.0"
    }


# Outfit analysis endpoint
@app.post("/api/v1/analyze/outfit", response_model=OutfitAnalysisResponse)
async def analyze_outfit(request: OutfitAnalysisRequest):
    """
    Analyze an outfit photo and return structured signals about garments,
    style, and potential issues.
    """
    try:
        logger.info(f"Analyzing outfit from: {request.image_url}")
        result = await outfit_analyzer.analyze(request.image_url, request.context)
        return result
    except Exception as e:
        logger.error(f"Error analyzing outfit: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# Wardrobe item parsing endpoint
@app.post("/api/v1/parse/wardrobe_item", response_model=WardrobeItemResponse)
async def parse_wardrobe_item(request: WardrobeItemRequest):
    """
    Parse a wardrobe item photo and extract metadata like category,
    colors, style, formality, etc.
    """
    try:
        logger.info(f"Parsing wardrobe item from: {request.image_url}")
        result = await wardrobe_parser.parse(request.image_url)
        return result
    except Exception as e:
        logger.error(f"Error parsing wardrobe item: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# Embedding generation endpoint
@app.post("/api/v1/embed/wardrobe_item", response_model=EmbeddingResponse)
async def embed_wardrobe_item(request: EmbeddingRequest):
    """
    Generate embeddings for a wardrobe item using image and/or text.
    """
    try:
        logger.info(f"Generating embedding for item: {request.wardrobe_item_id}")
        embedding = await embedding_service.generate_embedding(
            image_url=request.image_url,
            text=request.text
        )
        return {
            "embedding": embedding,
            "dimension": len(embedding)
        }
    except Exception as e:
        logger.error(f"Error generating embedding: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# Outfit recommendation endpoint
@app.post("/api/v1/recommend/outfit", response_model=OutfitRecommendationResponse)
async def recommend_outfit(request: OutfitRecommendationRequest):
    """
    Generate outfit recommendations based on user context and wardrobe.
    """
    try:
        logger.info(f"Generating outfit recommendations for user: {request.user_id}")
        result = await outfit_recommender.generate_recommendations(
            user_id=request.user_id,
            context=request.context,
            outfit_signals=request.outfit_signals,
            limit=request.limit
        )
        return result
    except Exception as e:
        logger.error(f"Error generating recommendations: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# Metrics endpoint for Prometheus
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    # TODO: Implement Prometheus metrics
    return {"status": "not implemented"}


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower()
    )

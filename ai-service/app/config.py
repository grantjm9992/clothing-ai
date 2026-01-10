"""
Configuration settings for AI Service
"""

from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # Server Configuration
    HOST: str = "0.0.0.0"
    PORT: int = 8001
    ENVIRONMENT: str = "development"
    DEBUG: bool = True

    # OpenAI Configuration
    OPENAI_API_KEY: Optional[str] = None
    OPENAI_MODEL: str = "gpt-4-vision-preview"
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-3-large"

    # Anthropic Configuration
    ANTHROPIC_API_KEY: Optional[str] = None
    ANTHROPIC_MODEL: str = "claude-3-opus-20240229"

    # Vector Database (Qdrant)
    QDRANT_URL: str = "http://localhost:6333"
    QDRANT_API_KEY: Optional[str] = None
    QDRANT_COLLECTION_NAME: str = "wardrobe_items"

    # AWS Configuration
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_DEFAULT_REGION: str = "us-east-1"
    AWS_BUCKET: Optional[str] = None

    # Model Configuration
    VISION_MODEL_PATH: str = "./models/vision"
    USE_GPU: bool = False
    BATCH_SIZE: int = 4
    MAX_WORKERS: int = 4

    # Logging and Monitoring
    LOG_LEVEL: str = "INFO"
    SENTRY_DSN: Optional[str] = None

    # Safety and Moderation
    ENABLE_CONTENT_MODERATION: bool = True
    MAX_IMAGE_SIZE_MB: int = 10
    ALLOWED_IMAGE_FORMATS: str = "jpg,jpeg,png,webp"

    # Performance
    REQUEST_TIMEOUT: int = 30
    MAX_CONCURRENT_REQUESTS: int = 10

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

# Clothing AI - AI Service

Python FastAPI service for AI-powered outfit analysis and wardrobe intelligence.

## Tech Stack

- **Framework**: FastAPI
- **AI/ML**: OpenAI GPT-4 Vision, Claude 3 Opus, PyTorch, Transformers
- **Vector Database**: Qdrant
- **Image Processing**: Pillow, OpenCV
- **Cloud**: AWS S3 for image storage

## Features

- Outfit photo analysis with garment detection
- Wardrobe item parsing and metadata extraction
- Vector embeddings generation (CLIP + text embeddings)
- Context-aware outfit recommendations
- Style scoring and feedback generation
- Content moderation and safety checks

## Local Development

### Prerequisites

- Python 3.11+
- Docker and Docker Compose

### Setup

1. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Copy environment file:
```bash
cp .env.example .env
```

4. Configure your API keys in `.env`:
   - OPENAI_API_KEY
   - ANTHROPIC_API_KEY (optional)
   - AWS credentials

5. Start Qdrant vector database:
```bash
docker-compose up -d qdrant
```

### Running the Service

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

Or with Docker:
```bash
docker-compose up
```

The API will be available at `http://localhost:8001`

API documentation: `http://localhost:8001/docs`

### Running Tests

```bash
pytest
```

## Project Structure

```
ai-service/
├── app/
│   ├── services/
│   │   ├── outfit_analyzer.py
│   │   ├── wardrobe_parser.py
│   │   ├── embedding_service.py
│   │   └── outfit_recommender.py
│   ├── models/
│   │   └── schemas.py
│   ├── utils/
│   │   ├── image_processing.py
│   │   └── color_analysis.py
│   └── config.py
├── tests/
├── models/  # Pre-trained models
├── main.py
└── requirements.txt
```

## API Endpoints

### Outfit Analysis
`POST /api/v1/analyze/outfit`

Analyzes an outfit photo and returns:
- Detected garments
- Style signals (formality, cohesion, contrast, etc.)
- Potential issues and risks

### Wardrobe Item Parsing
`POST /api/v1/parse/wardrobe_item`

Parses a wardrobe item photo and extracts:
- Category and subcategory
- Colors and patterns
- Material
- Formality level
- Season tags
- Style tags

### Embedding Generation
`POST /api/v1/embed/wardrobe_item`

Generates vector embeddings for similarity search using:
- Image embeddings (CLIP)
- Text embeddings (from metadata)

### Outfit Recommendations
`POST /api/v1/recommend/outfit`

Generates complete outfit recommendations based on:
- User context (occasion, weather, vibe)
- User's wardrobe items
- Style preferences
- Constraints

## AI Models

### Vision Models
- **GPT-4 Vision** for outfit analysis and item parsing
- **CLIP** for image embeddings
- **Custom segmentation** for garment detection

### Language Models
- **GPT-4** for styling advice and feedback
- **Claude 3 Opus** (alternative) for conversational refinement

### Embedding Strategy
- Multimodal embeddings combining image + text
- Stored in Qdrant for fast similarity search
- Filtered by user_id and category

## Performance Targets

- Outfit analysis: < 8s P95
- Wardrobe parsing: < 10s P95
- Vector search: < 300ms P95

## Deployment

See `/docs/ai-service-deployment.md` for production deployment instructions.

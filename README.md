# Clothing AI - AI Outfit Coach

> Your personal AI stylist that sees what you're wearing, knows your wardrobe, and tells you what to improve.

An AI-powered outfit coaching application that helps users make better fashion decisions through computer vision, machine learning, and personalized recommendations.

## 📋 Project Overview

Clothing AI is a full-stack monorepo containing three main projects:

- **Backend** - Laravel REST API for user management, wardrobe storage, and business logic
- **AI Service** - Python FastAPI service for outfit analysis and ML operations
- **Mobile** - Flutter mobile app for iOS and Android

## 🏗️ Architecture

```
clothing-ai/
├── backend/          # Laravel 11 REST API
├── ai-service/       # Python FastAPI AI service
├── mobile/           # Flutter mobile app
├── docs/             # Documentation
├── .github/          # CI/CD workflows
└── docker-compose.yml
```

### Tech Stack

| Component | Technology |
|-----------|-----------|
| **Backend API** | Laravel 11, PHP 8.2, PostgreSQL, Redis |
| **AI Service** | Python 3.11, FastAPI, PyTorch, OpenAI, Anthropic |
| **Vector DB** | Qdrant |
| **Mobile** | Flutter 3.16+, Riverpod |
| **Storage** | AWS S3 (production), MinIO (local) |
| **Queue** | AWS SQS (production), Redis (local) |
| **Auth** | Laravel Sanctum, OAuth (Google, Apple) |
| **Payments** | Stripe, Apple IAP, Google Play Billing |

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Make (optional, for convenience commands)
- Git

### Setup & Run

```bash
# Clone the repository
git clone https://github.com/yourusername/clothing-ai.git
cd clothing-ai

# Initial setup (copies .env files, starts services, runs migrations)
make setup

# Or manually:
cp .env.example .env
docker-compose up -d
docker-compose exec backend php artisan migrate
```

### Access Services

- **Backend API**: http://localhost:8000
- **AI Service**: http://localhost:8001
- **AI Service Docs**: http://localhost:8001/docs
- **Mailpit (Email)**: http://localhost:8025
- **MinIO Console**: http://localhost:9001

### Development Commands

```bash
# Start all services
make up

# View logs
make logs

# Stop all services
make down

# Run tests
make test

# Clean everything
make clean

# Rebuild containers
make rebuild
```

## 📱 Projects

### Backend (Laravel)

Laravel-based REST API handling:
- User authentication & profiles
- Wardrobe item management
- Outfit session processing
- Subscription management
- Media upload with pre-signed URLs
- Background job processing

[📖 Backend Documentation](./backend/README.md)

### AI Service (FastAPI)

Python AI service providing:
- Outfit photo analysis
- Wardrobe item parsing
- Vector embeddings generation
- Outfit recommendations
- Style scoring & feedback

[📖 AI Service Documentation](./ai-service/README.md)

### Mobile (Flutter)

Cross-platform mobile app featuring:
- Outfit photo capture & analysis
- Wardrobe digitization
- AI-powered outfit builder
- Saved outfits & packing lists
- Freemium subscription model

[📖 Mobile Documentation](./mobile/README.md)

## 🎯 Key Features

### 1️⃣ Outfit Check (Daily Hook)
- Take a photo of your outfit
- Get instant AI feedback
- Receive improvement suggestions
- See confidence scores

### 2️⃣ Wardrobe Intelligence
- Photograph your wardrobe items
- Auto-detection of category, color, style
- Smart organization and tagging
- Visual wardrobe management

### 3️⃣ Outfit Builder
- Generate complete outfits from your wardrobe
- Context-aware recommendations (occasion, weather, vibe)
- Swap individual items
- Save favorite combinations

### 4️⃣ Smart Recommendations
- AI-powered styling advice
- Learn your preferences over time
- Identify wardrobe gaps
- Seasonal suggestions

## 🔧 Development

### Running Individual Services

#### Backend Only
```bash
cd backend
composer install
php artisan serve
```

#### AI Service Only
```bash
cd ai-service
pip install -r requirements.txt
uvicorn main:app --reload
```

#### Mobile Only
```bash
cd mobile
flutter pub get
flutter run
```

### Database Migrations

```bash
# Create migration
docker-compose exec backend php artisan make:migration create_table_name

# Run migrations
docker-compose exec backend php artisan migrate

# Rollback
docker-compose exec backend php artisan migrate:rollback
```

### Running Tests

```bash
# All tests
make test

# Backend only
cd backend && php artisan test

# AI service only
cd ai-service && pytest

# Mobile only
cd mobile && flutter test
```

## 📊 Database Schema

See [Database Schema Documentation](./docs/SPECIFICATION.md#4-data-model-postgres) for detailed schema information including:
- Users & authentication
- Wardrobe items
- Outfit sessions & feedback
- Subscriptions & billing

## 🔐 Environment Configuration

Each project has its own `.env` file:

- **Root** `.env` - Docker Compose configuration
- **Backend** `backend/.env` - Laravel configuration
- **AI Service** `ai-service/.env` - Python service configuration

Copy the `.env.example` files and configure:
- Database credentials
- API keys (OpenAI, Anthropic)
- OAuth credentials (Google, Apple)
- Payment provider keys (Stripe)
- AWS credentials

## 🚢 Deployment

### Backend & AI Service
- Docker containers via ECS/Fargate or Kubernetes
- PostgreSQL on AWS RDS
- Redis on ElastiCache
- S3 for media storage
- SQS for job queues

### Mobile
- iOS: TestFlight → App Store
- Android: Internal Testing → Google Play
- CI/CD via Fastlane

See individual project READMEs for detailed deployment instructions.

## 📖 Documentation

- [📋 Full Product Specification](./docs/SPECIFICATION.md)
- [🗄️ Database Schema](./docs/SPECIFICATION.md#4-data-model-postgres)
- [🔌 API Documentation](http://localhost:8000/api/documentation) (when running)
- [🤖 AI Service API](http://localhost:8001/docs) (when running)

## 🧪 Testing Strategy

- **Backend**: PHPUnit, Feature tests, Unit tests
- **AI Service**: Pytest, Golden dataset tests, Schema validation
- **Mobile**: Flutter widget tests, Integration tests

## 🔄 CI/CD

GitHub Actions workflows for:
- Automated testing on push/PR
- Code linting and formatting
- Docker image building
- Deployment to staging/production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 🙋 Support

For questions or issues:
- Open an issue on GitHub
- Check the [documentation](./docs/)
- Review individual project READMEs

## 🎨 Product Vision

Clothing AI aims to be your personal AI stylist that:
- **Reduces decision fatigue** around daily outfit choices
- **Builds confidence** through constructive feedback
- **Maximizes your wardrobe** by suggesting new combinations
- **Teaches style** through explanations, not just recommendations
- **Respects privacy** with secure, encrypted photo storage

For the complete product vision and specification, see [SPECIFICATION.md](./docs/SPECIFICATION.md).

---

Built with ❤️ for people who want to look good without thinking too hard about it.

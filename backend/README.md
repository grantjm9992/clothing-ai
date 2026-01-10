# Clothing AI - Backend API

Laravel-based REST API for the AI Outfit Coach application.

## Tech Stack

- **Framework**: Laravel 11
- **Database**: PostgreSQL 16
- **Cache/Session**: Redis 7
- **Queue**: AWS SQS (production) / Redis (development)
- **Storage**: AWS S3
- **Authentication**: Laravel Sanctum + OAuth (Google, Apple, Facebook)

## Features

- User authentication and profile management
- Media upload with pre-signed URLs
- Wardrobe item management
- Outfit session processing
- Subscription management (Apple, Google, Stripe)
- Queue-based background job processing
- Admin panel for content moderation

## Local Development

### Prerequisites

- Docker and Docker Compose
- PHP 8.2+
- Composer

### Setup

1. Copy environment file:
```bash
cp .env.example .env
```

2. Start Docker containers:
```bash
docker-compose up -d
```

3. Install dependencies:
```bash
composer install
```

4. Generate application key:
```bash
php artisan key:generate
```

5. Run migrations:
```bash
php artisan migrate
```

6. Seed database (optional):
```bash
php artisan db:seed
```

### Running the Application

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

### Running Tests

```bash
php artisan test
```

## Project Structure

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Auth/
│   │   │   ├── Media/
│   │   │   ├── Wardrobe/
│   │   │   ├── Outfit/
│   │   │   └── Billing/
│   │   └── Middleware/
│   ├── Models/
│   ├── Jobs/
│   └── Services/
├── database/
│   ├── migrations/
│   └── seeders/
├── routes/
│   └── api.php
└── tests/
```

## API Documentation

API documentation is available at `/api/documentation` when running in development mode.

### Key Endpoints

- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/media/presign` - Get pre-signed upload URL
- `GET /api/v1/wardrobe/items` - List wardrobe items
- `POST /api/v1/outfits/sessions` - Create outfit analysis session
- `GET /api/v1/billing/status` - Get subscription status

## Database Schema

See `/docs/database-schema.md` for detailed database schema documentation.

## Background Jobs

- `ProcessWardrobeItemJob` - Process uploaded wardrobe items
- `ProcessOutfitSessionJob` - Analyze outfit photos and generate feedback
- `CleanupOldMediaJob` - Clean up old temporary media files

## Deployment

See `/docs/deployment.md` for production deployment instructions.

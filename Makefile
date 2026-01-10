.PHONY: help install up down logs clean test

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install all dependencies
	@echo "Installing backend dependencies..."
	cd backend && composer install
	@echo "Installing AI service dependencies..."
	cd ai-service && pip install -r requirements.txt
	@echo "Installing mobile dependencies..."
	cd mobile && flutter pub get

up: ## Start all services with Docker Compose
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## View logs from all services
	docker-compose logs -f

logs-backend: ## View backend logs
	docker-compose logs -f backend

logs-ai: ## View AI service logs
	docker-compose logs -f ai-service

clean: ## Clean up containers and volumes
	docker-compose down -v
	rm -rf backend/vendor
	rm -rf ai-service/__pycache__
	rm -rf mobile/.dart_tool

rebuild: ## Rebuild all containers
	docker-compose down
	docker-compose build --no-cache
	docker-compose up -d

test: ## Run tests for all projects
	@echo "Running backend tests..."
	cd backend && php artisan test
	@echo "Running AI service tests..."
	cd ai-service && pytest
	@echo "Running mobile tests..."
	cd mobile && flutter test

backend-shell: ## Open shell in backend container
	docker-compose exec backend /bin/bash

ai-shell: ## Open shell in AI service container
	docker-compose exec ai-service /bin/bash

db-shell: ## Open PostgreSQL shell
	docker-compose exec postgres psql -U postgres -d clothing_ai

redis-cli: ## Open Redis CLI
	docker-compose exec redis redis-cli

setup: ## Initial setup for development
	@echo "Setting up Clothing AI development environment..."
	cp .env.example .env
	cp backend/.env.example backend/.env
	cp ai-service/.env.example ai-service/.env
	@echo "Starting services..."
	make up
	@echo "Waiting for services to be ready..."
	sleep 10
	@echo "Running migrations..."
	docker-compose exec backend php artisan migrate
	@echo "Setup complete!"

dev: ## Start development environment
	@echo "Starting development environment..."
	make up
	@echo "Services started:"
	@echo "  Backend API: http://localhost:8000"
	@echo "  AI Service: http://localhost:8001"
	@echo "  API Docs: http://localhost:8001/docs"
	@echo "  Mailpit: http://localhost:8025"
	@echo "  MinIO Console: http://localhost:9001"

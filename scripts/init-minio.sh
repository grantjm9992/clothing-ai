#!/bin/bash

# Initialize MinIO bucket for Clothing AI
# This script creates the 'clothing-ai' bucket in MinIO

echo "Initializing MinIO bucket..."

# Wait for MinIO to be ready
echo "Waiting for MinIO to be healthy..."
until docker exec clothing-ai-minio mc alias set myminio http://localhost:9000 minioadmin minioadmin 2>/dev/null; do
  echo "MinIO not ready yet, waiting..."
  sleep 2
done

echo "MinIO is ready!"

# Create bucket
echo "Creating bucket 'clothing-ai'..."
docker exec clothing-ai-minio mc mb myminio/clothing-ai --ignore-existing

# Set bucket policy to allow public read (optional - for development only)
echo "Setting bucket policy..."
docker exec clothing-ai-minio mc anonymous set download myminio/clothing-ai

echo "✅ MinIO bucket 'clothing-ai' created successfully!"
echo "MinIO Console: http://localhost:9001"
echo "Username: minioadmin"
echo "Password: minioadmin"

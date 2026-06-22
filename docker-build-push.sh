#!/bin/bash

# Docker Build and Push Script for Apollo Customer Manager - RQ Worker
# This script builds the Docker image and pushes it to Docker Hub

set -e  # Exit on any error

# Configuration
IMAGE_NAME="marcandres888/acm-rq-worker"
TAG="${1:-latest}"  # Default to 'latest' if no tag provided

echo "=================================================="
echo "ACM RQ Worker - Docker Build & Push"
echo "=================================================="
echo "Image: $IMAGE_NAME:$TAG"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if logged in to Docker Hub
if ! docker info 2>&1 | grep -q "Username"; then
    echo "⚠️  Not logged in to Docker Hub"
    read -p "Do you want to login now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker login
    else
        echo "❌ Please login to Docker Hub first: docker login"
        exit 1
    fi
fi

# Build the image
echo "🔨 Building Docker image..."
docker build -t "$IMAGE_NAME:$TAG" .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

# Tag as latest if building a version tag
if [ "$TAG" != "latest" ]; then
    echo ""
    echo "🏷️  Tagging as latest..."
    docker tag "$IMAGE_NAME:$TAG" "$IMAGE_NAME:latest"
fi

# Push to Docker Hub
echo ""
echo "📤 Pushing to Docker Hub..."
docker push "$IMAGE_NAME:$TAG"

if [ $? -eq 0 ]; then
    echo "✅ Push successful: $IMAGE_NAME:$TAG"
else
    echo "❌ Push failed!"
    exit 1
fi

# Push latest tag if we created it
if [ "$TAG" != "latest" ]; then
    echo ""
    echo "📤 Pushing latest tag..."
    docker push "$IMAGE_NAME:latest"
    
    if [ $? -eq 0 ]; then
        echo "✅ Push successful: $IMAGE_NAME:latest"
    else
        echo "❌ Push failed for latest tag!"
        exit 1
    fi
fi

echo ""
echo "=================================================="
echo "✅ All Done!"
echo "=================================================="
echo "Images available at:"
echo "  - $IMAGE_NAME:$TAG"
if [ "$TAG" != "latest" ]; then
    echo "  - $IMAGE_NAME:latest"
fi
echo ""
echo "To run on production:"
echo "  docker pull $IMAGE_NAME:$TAG"
echo "  docker run -d --name acm-rq-worker \\"
echo "    --restart unless-stopped \\"
echo "    -e REDIS_URL=redis://10.42.4.19:32768/0 \\"
echo "    -e APOLLO_PROVISIONER_URL=http://10.42.4.19:8004/api/v1 \\"
echo "    -e GOTIFY_URL=http://10.42.4.19:8089 \\"
echo "    -e GOTIFY_CLIENT_KEY=your-gotify-key \\"
echo "    -e LOG_LEVEL=INFO \\"
echo "    $IMAGE_NAME:$TAG"
echo ""
echo "Or use docker-compose:"
echo "  docker-compose up -d --scale rq-worker=5"
echo "=================================================="

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ ./app/

# Create a non-root user
RUN useradd -m -u 1000 worker && chown -R worker:worker /app
USER worker

# Run RQ worker - using shell form to allow env var expansion
CMD rq worker device_tasks --url "$REDIS_URL"

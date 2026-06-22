# Apollo Customer Manager - RQ Worker

Standalone RQ (Redis Queue) worker container for processing background tasks.

## Features

- Separate container for RQ workers
- Scalable - run multiple workers easily
- Redis included in docker-compose
- Minimal dependencies (only what's needed for tasks)

## Quick Start

### 1. Setup Environment

```bash
cd acm-rq-worker
cp .env.example .env
# Edit .env with your configuration
```

### 2. Build and Run

```bash
# Build the image
docker-compose build

# Run 2 workers (default)
docker-compose up -d

# Scale to 5 workers
docker-compose up -d --scale rq-worker=5

# View logs
docker-compose logs -f rq-worker
```

### 3. Check Worker Status

```bash
# Access Redis CLI
docker exec -it acm-redis redis-cli

# In Redis CLI, check queue
> LLEN rq:queue:device_tasks
> KEYS rq:worker:*
```

## Configuration

Environment variables in `.env`:

- `REDIS_URL` - Redis connection URL (default: redis://redis:6379/0)
- `APOLLO_PROVISIONER_URL` - Device provisioner API URL
- `GOTIFY_URL` - Gotify server URL (optional)
- `GOTIFY_CLIENT_KEY` - Gotify client token (optional)
- `LOG_LEVEL` - Logging level (default: INFO)

## Scaling Workers

### Docker Compose

```bash
# Scale to 10 workers
docker-compose up -d --scale rq-worker=10

# Scale down to 1 worker
docker-compose up -d --scale rq-worker=1
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: acm-rq-worker
spec:
  replicas: 5  # Number of workers
  selector:
    matchLabels:
      app: acm-rq-worker
  template:
    metadata:
      labels:
        app: acm-rq-worker
    spec:
      containers:
      - name: worker
        image: acm-rq-worker:latest
        env:
        - name: REDIS_URL
          value: "redis://redis-service:6379/0"
        - name: APOLLO_PROVISIONER_URL
          value: "http://device-provisioner:8004/api/v1"
```

## Development

### Running Locally

```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export REDIS_URL=redis://10.42.4.19:32768/0
export APOLLO_PROVISIONER_URL=http://10.42.4.19:8004/api/v1

# Run worker
rq worker device_tasks --url $REDIS_URL
```

### Adding New Tasks

1. Create task function in `app/tasks/device_tasks.py` or new file
2. Import in main app and queue with `task_queue.enqueue()`
3. Rebuild worker container if needed

## Monitoring

### RQ Dashboard (Optional)

```bash
# Add to docker-compose.yml
rq-dashboard:
  image: eoranged/rq-dashboard
  ports:
    - "9181:9181"
  environment:
    - RQ_DASHBOARD_REDIS_URL=redis://redis:6379/0
  networks:
    - apollo-network
```

Then access at http://localhost:9181

## Troubleshooting

### Workers not processing jobs

1. Check Redis connection:
   ```bash
   docker-compose logs redis
   ```

2. Check worker logs:
   ```bash
   docker-compose logs rq-worker
   ```

3. Verify queue exists:
   ```bash
   docker exec -it acm-redis redis-cli LLEN rq:queue:device_tasks
   ```

### High memory usage

Reduce number of workers or add memory limits:

```yaml
deploy:
  resources:
    limits:
      memory: 512M
    reservations:
      memory: 256M
```

## Production Deployment

1. Use external Redis (managed service recommended)
2. Set appropriate worker count based on load
3. Configure health checks
4. Set up monitoring and alerting
5. Use secrets management for sensitive env vars

## Network

The docker-compose uses `apollo-network` (external). Create it first:

```bash
docker network create apollo-network
```

Or change to a local network in docker-compose.yml:

```yaml
networks:
  apollo-network:
    driver: bridge
```

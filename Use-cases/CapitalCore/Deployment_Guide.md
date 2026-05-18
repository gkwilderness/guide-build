---
title: "Deployment_Guide"
type: project
area: wilderness
project: "Wilderness"
status: active
---
# Deployment Guide

## Overview

Complete deployment instructions for the yield curve analytics system, from local development to production demo environment for Nick presentation.

## Deployment Architecture

### Local Development

```
Developer Machine (Ubuntu)
├── Docker Compose Stack
│   ├── PostgreSQL Database
│   ├── Redis (for Celery)
│   └── Streamlit App
├── Python Environment
└── AI Development Tools
```

### Production Demo Environment

```
Cloud Server (Ubuntu)
├── Docker Compose Stack
│   ├── PostgreSQL Database
│   ├── Redis Cache
│   ├── Streamlit Dashboard
│   ├── Celery Worker
│   └── Nginx Reverse Proxy
├── SSL Certificate
└── Backup System
```

## Local Development Setup

### Prerequisites

```bash
# System requirements
- Ubuntu 20.04+ (or WSL2 on Windows)
- Docker 20.10+
- Docker Compose 2.0+
- Python 3.9+
- Git

# Install Docker and Docker Compose
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Log out and back in for group changes
```

### Project Structure

```
yield-curve-system/
├── docker-compose.yml
├── docker-compose.prod.yml
├── Dockerfile
├── requirements.txt
├── .env.template
├── .env.local
├── .env.prod
├── src/
│   ├── streamlit_app.py
│   ├── services/
│   ├── models/
│   ├── utils/
│   └── config/
├── sql/
│   ├── schema.sql
│   ├── migrations/
│   └── seed_data.sql
├── docs/
├── tests/
└── scripts/
    ├── setup_local.sh
    ├── deploy_prod.sh
    └── backup_db.sh
```

### Environment Configuration

#### .env.template

```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=yield_curves
DB_USER=postgres
DB_PASSWORD=your_secure_password

# Google Ads API
GOOGLE_ADS_DEVELOPER_TOKEN=your_developer_token
GOOGLE_ADS_CLIENT_ID=your_client_id
GOOGLE_ADS_CLIENT_SECRET=your_client_secret
GOOGLE_ADS_REFRESH_TOKEN=your_refresh_token

# Business-specific Google Ads Account IDs
WILDERNESS_GOOGLE_ADS_ACCOUNT_ID=123-456-7890
JACADA_GOOGLE_ADS_ACCOUNT_ID=234-567-8901
YELLOWZEBRA_GOOGLE_ADS_ACCOUNT_ID=345-678-9012

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# Application Configuration
APP_ENV=development
LOG_LEVEL=INFO
SECRET_KEY=your_secret_key_for_sessions

# Streamlit Configuration
STREAMLIT_SERVER_PORT=8501
STREAMLIT_SERVER_ADDRESS=0.0.0.0
```

#### .env.local (Development)

```bash
# Copy from .env.template and fill in development values
DB_HOST=postgres
DB_PASSWORD=dev_password_123
APP_ENV=development
LOG_LEVEL=DEBUG

# Use test Google Ads accounts for development
WILDERNESS_GOOGLE_ADS_ACCOUNT_ID=your_test_account
```

#### .env.prod (Production)

```bash
# Production environment variables
DB_HOST=postgres
DB_PASSWORD=super_secure_prod_password_456
APP_ENV=production
LOG_LEVEL=INFO

# Production Google Ads accounts
WILDERNESS_GOOGLE_ADS_ACCOUNT_ID=real_production_account
```

### Docker Configuration

#### docker-compose.yml (Local Development)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: yield_curves_db
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./sql/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./sql/seed_data.sql:/docker-entrypoint-initdb.d/02-seed.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: yield_curves_redis
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  streamlit:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: yield_curves_app
    ports:
      - "8501:8501"
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    env_file:
      - .env.local
    volumes:
      - ./src:/app/src
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  celery:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: yield_curves_worker
    command: celery -A src.tasks worker --loglevel=info
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    env_file:
      - .env.local
    volumes:
      - ./src:/app/src
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  default:
    name: yield_curves_network
```

#### Dockerfile

```dockerfile
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/
COPY sql/ ./sql/

# Create logs directory
RUN mkdir -p logs

# Set environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Default command (can be overridden)
CMD ["streamlit", "run", "src/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

#### requirements.txt

```txt
# Core dependencies
streamlit==1.29.0
pandas==2.1.4
numpy==1.24.3
psycopg2-binary==2.9.9
redis==5.0.1
celery==5.3.4

# Google Ads API
google-ads==22.1.0

# Data visualization
plotly==5.17.0
matplotlib==3.8.2

# Utilities
python-dotenv==1.0.0
pydantic==2.5.2
loguru==0.7.2

# Development and testing
pytest==7.4.3
pytest-cov==4.1.0
black==23.12.0
flake8==6.1.0

# Production dependencies
gunicorn==21.2.0
```

### Local Setup Scripts

#### scripts/setup_local.sh

```bash
#!/bin/bash
set -e

echo "🚀 Setting up local development environment..."

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose is required but not installed."; exit 1; }

# Create environment file if it doesn't exist
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local from template..."
    cp .env.template .env.local
    echo "⚠️  Please edit .env.local with your actual Google Ads API credentials"
fi

# Create necessary directories
mkdir -p logs
mkdir -p data/postgres
mkdir -p data/redis

# Set proper permissions
chmod +x scripts/*.sh

# Build and start services
echo "🏗️  Building Docker containers..."
docker-compose build

echo "🚀 Starting services..."
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Check service health
echo "🔍 Checking service health..."
docker-compose ps

# Show logs
echo "📋 Recent logs:"
docker-compose logs --tail=20

echo "✅ Local development environment is ready!"
echo "🌐 Streamlit app: http://localhost:8501"
echo "🗄️  PostgreSQL: localhost:5432"
echo "⚡ Redis: localhost:6379"
echo ""
echo "To view logs: docker-compose logs -f"
echo "To stop services: docker-compose down"
```

#### scripts/check_health.sh

```bash
#!/bin/bash

echo "🏥 Health Check Status:"
echo "====================="

# Check Docker containers
echo "📦 Container Status:"
docker-compose ps

echo ""
echo "🔍 Service Health Checks:"

# Check PostgreSQL
if docker-compose exec -T postgres pg_isready -U postgres -d yield_curves >/dev/null 2>&1; then
    echo "✅ PostgreSQL: Healthy"
else
    echo "❌ PostgreSQL: Unhealthy"
fi

# Check Redis
if docker-compose exec -T redis redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis: Healthy"
else
    echo "❌ Redis: Unhealthy"
fi

# Check Streamlit
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8501/_stcore/health | grep -q "200"; then
    echo "✅ Streamlit: Healthy"
else
    echo "❌ Streamlit: Unhealthy"
fi

echo ""
echo "📊 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

## Production Deployment

### Cloud Server Setup

#### Server Requirements

```
Minimum Specifications:
- CPU: 2 vCPUs
- RAM: 4GB
- Storage: 20GB SSD
- OS: Ubuntu 20.04 LTS
- Network: Static IP address

Recommended for Demo:
- CPU: 4 vCPUs  
- RAM: 8GB
- Storage: 40GB SSD
- Backup: 10GB additional storage
```

#### Initial Server Configuration

```bash
#!/bin/bash
# Run as root on fresh Ubuntu server

# Update system
apt update && apt upgrade -y

# Install essential packages
apt install -y \
    docker.io \
    docker-compose-plugin \
    nginx \
    certbot \
    python3-certbot-nginx \
    git \
    htop \
    curl \
    vim

# Configure Docker
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Configure firewall
ufw allow ssh
ufw allow 80
ufw allow 443
ufw --force enable

# Create application directory
mkdir -p /opt/yield-curves
chown ubuntu:ubuntu /opt/yield-curves

echo "✅ Server setup complete"
```

### Production Docker Configuration

#### docker-compose.prod.yml

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: yield_curves_db_prod
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data_prod:/var/lib/postgresql/data
      - ./sql/schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
      - ./backups:/backups
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 30s
      timeout: 10s
      retries: 3

  redis:
    image: redis:7-alpine
    container_name: yield_curves_redis_prod
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data_prod:/data
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "--no-auth-warning", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 30s
      timeout: 10s
      retries: 3

  streamlit:
    build:
      context: .
      dockerfile: Dockerfile.prod
    container_name: yield_curves_app_prod
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    env_file:
      - .env.prod
    volumes:
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8501/_stcore/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  celery:
    build:
      context: .
      dockerfile: Dockerfile.prod
    container_name: yield_curves_worker_prod
    command: celery -A src.tasks worker --loglevel=info --concurrency=2
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    env_file:
      - .env.prod
    volumes:
      - ./logs:/app/logs
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: always

  nginx:
    image: nginx:alpine
    container_name: yield_curves_nginx_prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
      - /etc/letsencrypt:/etc/letsencrypt
    depends_on:
      - streamlit
    restart: always

volumes:
  postgres_data_prod:
  redis_data_prod:

networks:
  default:
    name: yield_curves_prod_network
```

#### Dockerfile.prod

```dockerfile
FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/
COPY sql/ ./sql/

# Create logs directory
RUN mkdir -p logs

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Environment variables
ENV PYTHONPATH=/app
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Command
CMD ["streamlit", "run", "src/streamlit_app.py", "--server.port=8501", "--server.address=0.0.0.0"]
```

### Nginx Configuration

#### nginx/nginx.conf

```nginx
events {
    worker_connections 1024;
}

http {
    upstream streamlit {
        server streamlit:8501;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=streamlit_limit:10m rate=10r/s;

    server {
        listen 80;
        server_name your-domain.com;
        
        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com;

        # SSL Configuration
        ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

        # Gzip compression
        gzip on;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

        # Rate limiting
        limit_req zone=streamlit_limit burst=20 nodelay;

        location / {
            proxy_pass http://streamlit;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # WebSocket support for Streamlit
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # Health check endpoint
        location /health {
            proxy_pass http://streamlit/_stcore/health;
            access_log off;
        }

        # Static files caching
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            proxy_pass http://streamlit;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

### Deployment Scripts

#### scripts/deploy_prod.sh

```bash
#!/bin/bash
set -e

DEPLOY_USER="ubuntu"
DEPLOY_HOST="your-server-ip"
DEPLOY_PATH="/opt/yield-curves"

echo "🚀 Deploying to production server..."

# Copy files to server
echo "📁 Copying files to server..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='__pycache__' \
    --exclude='.env.local' \
    --exclude='data/' \
    . ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}/

# Execute deployment on server
ssh ${DEPLOY_USER}@${DEPLOY_HOST} << EOF
    cd ${DEPLOY_PATH}
    
    echo "🔧 Setting up production environment..."
    
    # Ensure .env.prod exists
    if [ ! -f .env.prod ]; then
        echo "❌ .env.prod file missing! Please create it with production values."
        exit 1
    fi
    
    # Build and deploy
    echo "🏗️  Building production containers..."
    docker-compose -f docker-compose.prod.yml build --no-cache
    
    echo "🔄 Stopping existing services..."
    docker-compose -f docker-compose.prod.yml down
    
    echo "🚀 Starting production services..."
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services to be ready
    echo "⏳ Waiting for services to start..."
    sleep 30
    
    # Check health
    echo "🔍 Checking service health..."
    docker-compose -f docker-compose.prod.yml ps
    
    # Show logs
    echo "📋 Recent logs:"
    docker-compose -f docker-compose.prod.yml logs --tail=10
    
    echo "✅ Production deployment complete!"
EOF

echo "🌐 Application should be available at https://your-domain.com"
```

### SSL Certificate Setup

#### scripts/setup_ssl.sh

```bash
#!/bin/bash
# Run on production server

DOMAIN="your-domain.com"
EMAIL="your-email@domain.com"

echo "🔒 Setting up SSL certificate for ${DOMAIN}..."

# Stop nginx if running
docker-compose -f docker-compose.prod.yml stop nginx

# Get certificate
certbot certonly --standalone \
    --email ${EMAIL} \
    --agree-tos \
    --no-eff-email \
    -d ${DOMAIN}

# Start nginx with new certificate
docker-compose -f docker-compose.prod.yml up -d nginx

# Setup automatic renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

echo "✅ SSL certificate setup complete"
```

## Backup and Recovery

### Database Backup Script

#### scripts/backup_db.sh

```bash
#!/bin/bash
set -e

BACKUP_DIR="/opt/yield-curves/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql"

# Create backup directory
mkdir -p ${BACKUP_DIR}

echo "💾 Creating database backup..."

# Create backup
docker-compose -f docker-compose.prod.yml exec -T postgres pg_dump \
    -U postgres \
    -d yield_curves \
    --no-owner \
    --no-privileges \
    > ${BACKUP_FILE}

# Compress backup
gzip ${BACKUP_FILE}

echo "✅ Backup created: ${BACKUP_FILE}.gz"

# Clean old backups (keep last 7 days)
find ${BACKUP_DIR} -name "db_backup_*.sql.gz" -mtime +7 -delete

# Upload to cloud storage (optional)
# aws s3 cp ${BACKUP_FILE}.gz s3://your-backup-bucket/
```

### Automated Backup Cron Job

```bash
# Add to crontab with: crontab -e
# Daily backup at 2 AM
0 2 * * * /opt/yield-curves/scripts/backup_db.sh >> /var/log/yield-curves-backup.log 2>&1
```

### Database Recovery

```bash
#!/bin/bash
# scripts/restore_db.sh

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file.sql.gz>"
    exit 1
fi

echo "🔄 Restoring database from ${BACKUP_FILE}..."

# Extract backup if compressed
if [[ $BACKUP_FILE == *.gz ]]; then
    gunzip -c $BACKUP_FILE | docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d yield_curves
else
    cat $BACKUP_FILE | docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d yield_curves
fi

echo "✅ Database restored successfully"
```

## Monitoring and Maintenance

### System Monitoring Script

```bash
#!/bin/bash
# scripts/monitor_system.sh

echo "📊 System Status Report - $(date)"
echo "=================================="

# Container status
echo "🐳 Container Status:"
docker-compose -f docker-compose.prod.yml ps

# Resource usage
echo ""
echo "💻 Resource Usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# Disk usage
echo ""
echo "💽 Disk Usage:"
df -h /opt/yield-curves

# Database size
echo ""
echo "🗄️  Database Size:"
docker-compose -f docker-compose.prod.yml exec postgres psql -U postgres -d yield_curves -c "
SELECT 
    pg_size_pretty(pg_database_size('yield_curves')) as database_size,
    (SELECT count(*) FROM daily_metrics) as daily_metrics_count,
    (SELECT count(*) FROM campaigns) as campaigns_count;
"

# Recent logs
echo ""
echo "📋 Recent Error Logs:"
docker-compose -f docker-compose.prod.yml logs --tail=10 | grep -i error || echo "No recent errors"
```

### Maintenance Tasks

#### scripts/maintenance.sh

```bash
#!/bin/bash
# Weekly maintenance tasks

echo "🧹 Running weekly maintenance..."

# Clean up old Docker images
docker image prune -f

# Clean up old logs (keep last 30 days)
find /opt/yield-curves/logs -name "*.log" -mtime +30 -delete

# Vacuum database
docker-compose -f docker-compose.prod.yml exec postgres psql -U postgres -d yield_curves -c "VACUUM ANALYZE;"

# Restart services to clear memory
docker-compose -f docker-compose.prod.yml restart

echo "✅ Maintenance complete"
```

## Demo Environment Preparation

### Pre-Demo Checklist

```bash
#!/bin/bash
# scripts/demo_checklist.sh

echo "🎯 Demo Environment Checklist"
echo "============================"

# Check all services are running
echo "✅ Checking services..."
./scripts/check_health.sh

# Verify data freshness
echo "✅ Checking data freshness..."
docker-compose -f docker-compose.prod.yml exec postgres psql -U postgres -d yield_curves -c "
SELECT 
    'Latest daily metrics: ' || MAX(date) as latest_data,
    'Total campaigns: ' || COUNT(DISTINCT campaign_id) as campaign_count
FROM daily_metrics;
"

# Test key dashboard pages
echo "✅ Testing dashboard pages..."
curl -s -o /dev/null -w "Portfolio Overview: %{http_code}\n" "https://your-domain.com"
curl -s -o /dev/null -w "Health Check: %{http_code}\n" "https://your-domain.com/health"

# Check SSL certificate
echo "✅ SSL Certificate Status:"
echo | openssl s_client -servername your-domain.com -connect your-domain.com:443 2>/dev/null | openssl x509 -noout -dates

# Performance test
echo "✅ Performance Test:"
time curl -s "https://your-domain.com" > /dev/null

echo ""
echo "🎯 Demo environment ready for Nick!"
```

## Troubleshooting

### Common Issues and Solutions

#### Database Connection Issues

```bash
# Check database connectivity
docker-compose -f docker-compose.prod.yml exec postgres pg_isready -U postgres -d yield_curves

# View database logs
docker-compose -f docker-compose.prod.yml logs postgres

# Reset database connection pool
docker-compose -f docker-compose.prod.yml restart streamlit
```

#### Memory Issues

```bash
# Check memory usage
docker stats --no-stream

# Clear Redis cache
docker-compose -f docker-compose.prod.yml exec redis redis-cli FLUSHALL

# Restart services with memory cleanup
docker-compose -f docker-compose.prod.yml down
docker system prune -f
docker-compose -f docker-compose.prod.yml up -d
```

#### SSL Certificate Issues

```bash
# Renew certificate manually
certbot renew --force-renewal

# Test certificate
certbot certificates

# Restart nginx
docker-compose -f docker-compose.prod.yml restart nginx
```

This completes the comprehensive **deployment-guide.md**. Ready for the next document?
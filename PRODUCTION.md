# Production Deployment Guide

This application is containerized and ready for production deployment using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed on your production server
- Access to a PostgreSQL database or ability to run the containerized version
- SSL certificate for your domain (recommended for production)

## Deployment Steps

Follow these steps to deploy the application:

1. Copy the necessary files to your production server:

```bash
scp docker-compose.yml Dockerfile bin/docker-entrypoint user@your-server:/app/
```

1. Create a `.env` file based on the provided `.env.example`:

```bash
cp .env.example .env
# Edit .env with appropriate values
```

1. Make sure to set your `RAILS_MASTER_KEY` in the `.env` file (from `config/master.key`)

1. Build and start the application:

```bash
docker compose up -d
```

1. Verify that all services are running correctly:

```bash
docker compose ps
```

## Scaling

To scale the worker processes:

```bash
docker compose up -d --scale worker=3
```

## Logs

To view application logs:

```bash
docker compose logs -f web
```

## Maintenance

To run Rails console in production:

```bash
docker compose exec web bin/rails console
```

To run database migrations:

```bash
docker compose exec web bin/rails db:migrate
```

## Health Checks

The application has built-in health checks accessible at `/health` endpoint.

## Testing Production Setup Locally

To test the production setup on your local machine before deploying to a server:

1. Create a `.env` file with your production environment variables:

```bash
cp .env.example .env
# Fill in the necessary values but use localhost for hosts
```

1. Generate a local master key for testing if needed:

```bash
cd config
EDITOR=vi rails credentials:edit
# This will create master.key if it doesn't exist
```

1. Build the production containers locally:

```bash
docker compose build
```

1. Start the production setup:

```bash
docker compose up -d
```

1. Monitor the logs to ensure everything starts correctly:

```bash
docker compose logs -f
```

1. Access the application at `http://localhost:3000`

1. When finished testing, stop the containers:

```bash
docker compose down -v  # Add -v to remove volumes if needed
```

Note: When testing production mode locally, remember that:

- Asset compilation and optimization will be enabled
- Performance will be different from development mode
- Error pages will be static rather than showing detailed errors

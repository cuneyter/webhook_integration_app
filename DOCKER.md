# Docker Setup for Webhook Integration App

This document explains how to use Docker with the Webhook Integration App, a Rails 8 application using Solid Adapters and Propshaft asset pipeline.

## Prerequisites

- Docker and Docker Compose installed
- Environment-specific credentials keys (for production)

## Quick Start

### Production Environment

1. **Set up environment variables:**

   ```bash
   # For production, you only need the production credentials key
   export RAILS_MASTER_KEY=your_production_credentials_key
   ```

2. **Build and start the application:**

   ```bash
   docker-compose up --build
   ```

3. **Access the application:**
   - Web application: `http://localhost:3000`
   - Database: `localhost:5432`

### Development Environment

1. **Environment variables setup:**

   This application now uses dotenv-rails for development environment variables. Make sure you have an `.env` file in your project root with necessary configuration (database credentials, etc.):

   ```bash
   # Example .env file for development
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=postgres
   # Add other development environment variables here
   ```

   **Note:** The master key is now read directly from `config/master.key` and doesn't need to be specified in the `.env` file.

2. **Start development environment:**

   ```bash
   docker-compose -f docker-compose.dev.yml up --build
   ```

   This automatically sets up the database, runs migrations, and starts all services.

   **Note:** Rails is configured to bind to `0.0.0.0` in development (see `Procfile.dev`) so it is accessible from your host at `http://localhost:3000`.

## Services

### Production Services

- **web**: Rails application server
- **worker**: Background job processor (Solid Queue)
- **db**: PostgreSQL database

### Development Services

- **web**: Rails development server with hot reloading (binds to 0.0.0.0)
- **worker**: Background job processor
- **db**: PostgreSQL database

## Environment Variables

### Required Variables

#### Production Environment

- `RAILS_MASTER_KEY`: Production credentials key for decrypting `config/credentials/production.yml.enc`

#### Development Environment

- Uses dotenv-rails gem to load variables from `.env` file
- Credentials are read directly from `config/master.key` (mounted into container)

### Pre-configured Variables

The following variables are already configured in the docker-compose files:

- `MAILER_HOST=localhost:3000`: Host for mailer URLs
- `JOB_CONCURRENCY`: Number of job worker processes (3 in production, 1 in development)
- `RAILS_MAX_THREADS=5`: Maximum database connection pool size
- `RAILS_LOG_LEVEL=info`: Log level

### Database Connection Variables

The application automatically configures database connections using these environment variables:

- `DATABASE_URL`: Primary database connection
- `DATABASE_URL_QUEUE`: Solid Queue database connection
- `DATABASE_URL_CABLE`: Solid Cable database connection
- `DATABASE_URL_CACHE`: Solid Cache database connection

### Optional Override Variables

You can override the pre-configured variables by setting environment variables:

```bash
# Override MAILER_HOST for production
export MAILER_HOST=your-domain.com
docker-compose up --build

# Override job concurrency
export JOB_CONCURRENCY=5
docker-compose up --build
```

## Credentials Configuration

This application uses Rails 8's environment-specific credentials:

- **Development**: `config/credentials/development.yml.enc` (key stored in `config/credentials/development.key`)
- **Production**: `config/credentials/production.yml.enc` (key stored in `config/credentials/production.key`)
- **Default**: `config/credentials.yml.enc` (key stored in `config/master.key`)

In the development Docker environment, the `config/master.key` file is mounted directly into the container, so you don't need to set the `RAILS_MASTER_KEY` environment variable.

### Managing Credentials

To work with your Rails credentials:

1. **Check existing credential files:**

   ```bash
   find ./config -name "*.yml.enc" -o -name "*.key"
   ```

2. **Edit credentials:**

   ```bash
   # For development
   rails credentials:edit --environment development

   # For production
   rails credentials:edit --environment production

   # For default credentials
   rails credentials:edit
   ```

3. **View credentials:**

   ```bash
   # For development
   rails credentials:show --environment development

   # For production
   rails credentials:show --environment production

   # For default credentials
   rails credentials:show
   ```

## Database Configuration

The application uses multiple PostgreSQL databases for different purposes:

- **Primary**: Main application data
- **Queue**: Background job queue (Solid Queue)
- **Cable**: Action Cable real-time features (Solid Cable)
- **Cache**: Application caching (Solid Cache)

### Database Initialization

The Docker setup automatically creates all required databases using:

- **Initialization Script**: `docker-entrypoint-initdb.d/init-multiple-databases.sh`
- **Environment Variable**: `POSTGRES_MULTIPLE_DATABASES` lists all databases to create
- **Automatic Setup**: Databases are created when PostgreSQL container starts

### Database Connection Method

The application uses TCP connections to the database container:

- **Connection URLs**: Use `postgres://postgres:postgres@db:5432/database_name`
- **Container Networking**: Uses Docker's internal networking
- **No Unix Sockets**: Avoids local socket connection issues

### Automated Database Setup

The application now includes automated database setup:

- **Entrypoint Script**: `bin/docker-entrypoint` handles database initialization
- **Migration Automation**: Only the web service runs migrations to prevent race conditions
- **Health Checks**: Services wait for dependencies to be healthy before starting
- **No Manual Setup**: Database setup is fully automated on startup

## Asset Pipeline

This application uses Rails 8's modern asset pipeline:

- **Propshaft**: Asset pipeline (replaces Sprockets)
- **Importmap Rails**: JavaScript dependency management
- **Tailwind CSS Rails**: CSS framework via gem
- **No Node.js required**: All assets are compiled through Rails

## Health Checks

The services include comprehensive health checks:

- **Database**: Checks PostgreSQL connectivity using `pg_isready`
- **Web**: Checks `/health` endpoint to verify Rails application is ready
- **Worker**: Waits for web service to be healthy before starting
- **Dependencies**: Services wait for their dependencies to be healthy

### Health Check Endpoint

The application includes a `/health` endpoint for Docker health checks:

```ruby
# config/routes.rb
get '/health', to: proc { [200, {}, ['OK']] }
```

## Useful Commands

**Note:** Use `bin/rails` (not just `rails`) for all Rails commands inside the container.

### Production

```bash
# View logs
docker-compose logs -f web

# Run Rails console
docker-compose exec web bin/rails console

# Run database migrations
docker-compose exec web bin/rails db:migrate

# Precompile assets
docker-compose exec web bin/rails assets:precompile

# Restart services
docker-compose restart web worker

# Stop all services
docker-compose down
```

### Development

```bash
# View logs
docker-compose -f docker-compose.dev.yml logs -f web

# Run Rails console
docker-compose -f docker-compose.dev.yml exec web bin/rails console

# Run tests
docker-compose -f docker-compose.dev.yml exec web bin/rails test

# Run RSpec
docker-compose -f docker-compose.dev.yml exec web bundle exec rspec

# Access database
docker-compose -f docker-compose.dev.yml exec db psql -U postgres -d webhook_integration_app_development

# Watch and compile assets
docker-compose -f docker-compose.dev.yml exec web bin/rails tailwindcss:watch
```

## Troubleshooting

### Common Issues

1. **Permission errors:**

   ```bash
   sudo chown -R $USER:$USER .
   ```

2. **Database connection issues:**

   ```bash
   # Remove all containers and volumes
   docker-compose down -v
   docker-compose up --build
   ```

3. **Asset compilation errors:**

   ```bash
   docker-compose exec web bin/rails assets:precompile
   ```

4. **Job worker not starting:**

   ```bash
   docker-compose logs worker
   docker-compose restart worker
   ```

5. **Tailwind CSS not compiling:**

   ```bash
   docker-compose exec web bin/rails tailwindcss:build
   ```

6. **Credentials errors:**

   ```bash
   # For development:
   # Verify the master.key file exists
   ls -la config/master.key

   # Verify credentials can be decrypted
   docker-compose -f docker-compose.dev.yml exec web bin/rails credentials:show

   # For production:
   # Check if RAILS_MASTER_KEY is set
   echo $RAILS_MASTER_KEY

   # Verify credentials can be decrypted
   docker-compose exec web bin/rails credentials:show --environment production
   ```

7. **Database not found errors:**

   ```bash
   # Check if databases exist
   docker-compose exec db psql -U postgres -l

   # Recreate databases if needed
   docker-compose down -v
   docker-compose up --build
   ```

8. **Race condition errors (migrations running simultaneously):**

   ```bash
   # The new setup prevents this, but if you see it:
   docker-compose down -v
   docker-compose up --build
   ```

9. **Cannot access Rails app at `http://localhost:3000`:**
   - Ensure Rails is started with `-b 0.0.0.0` (see `Procfile.dev`)
   - Ensure Docker Compose port mapping is `3000:3000`
   - Try both `http://localhost:3000` and `http://127.0.0.1:3000`
   - Check for firewalls, VPNs, or security software blocking Docker traffic
   - Check logs with `docker-compose -f docker-compose.dev.yml logs -f web`

### Volume Management

```bash
# Remove all volumes (WARNING: This will delete all data)
docker-compose down -v

# Backup database
docker-compose exec db pg_dump -U postgres webhook_integration_app_production > backup.sql

# Restore database
docker-compose exec -T db psql -U postgres webhook_integration_app_production < backup.sql
```

## Performance Optimization

### Production

- Use multiple worker processes: `JOB_CONCURRENCY=3`
- Enable asset caching with Propshaft
- Use connection pooling
- Monitor resource usage
- Precompile assets during build

### Development

- Use volume mounts for hot reloading
- Cache bundle dependencies
- Enable debugging tools
- Use Tailwind CSS watch mode for live CSS updates

## Security Considerations

- Never commit credential keys
- Use environment variables for secrets
- Run containers as non-root user
- Keep base images updated
- Use health checks for monitoring
- No Node.js dependencies reduces attack surface

## Deployment

For production deployment, consider using:

- **Kamal**: Rails deployment tool
- **Docker Swarm**: Container orchestration
- **Kubernetes**: Container orchestration
- **Reverse proxy**: Nginx or Traefik

## Monitoring

Monitor the application using:

```bash
# Resource usage
docker stats

# Log analysis
docker-compose logs --tail=100 web

# Database connections
docker-compose exec db psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# Asset compilation status
docker-compose exec web bin/rails assets:environment

# Database status
docker-compose exec db psql -U postgres -l

# Health check status
docker-compose ps
```

## Build Optimization

The Dockerfiles are optimized for Rails 8:

- **Multi-stage builds**: Separate build and runtime stages
- **Propshaft assets**: No Node.js required for asset compilation
- **Bootsnap precompilation**: Faster application startup
- **Minimal dependencies**: Only essential packages installed
- **Security**: Non-root user execution
- **Database initialization**: Automatic setup of all required databases
- **Entrypoint scripts**: Automated database setup and migration handling
- **Health checks**: Comprehensive service health monitoring

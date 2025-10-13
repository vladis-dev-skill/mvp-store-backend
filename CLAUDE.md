# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **MVP Store Backend** service - a Symfony 7.3 application serving as the main backend API in a microservices architecture. It communicates with the separate **Payment Service** via HTTP and uses PostgreSQL and Redis for data storage and caching.

## Development Commands

### Docker-based Development
All development happens inside Docker containers. The application runs on **PHP 8.2+** with Symfony 7.3.

**Primary Commands:**
```bash
make init          # Full setup: stop containers, build, start, install deps, migrate
make up            # Start all containers (nginx, php-fpm, postgresql, redis)
make down          # Stop containers
make exec_bash     # Access PHP container shell for Symfony commands
make test          # Run PHPUnit tests inside container
```

**Individual Development Tasks:**
```bash
make composer-install    # Install/update Composer dependencies
make store-migrate       # Run database migrations
make fixer              # Run PHP-CS-Fixer code formatting
```

### Inside Container Commands
After `make exec_bash`, common Symfony commands:
```bash
php bin/console doctrine:migrations:diff     # Generate new migration
php bin/console doctrine:migrations:migrate  # Apply migrations
php bin/console cache:clear                  # Clear application cache
php bin/console debug:router                 # List all routes
composer install                             # Install PHP dependencies
php bin/phpunit                             # Run tests directly
```

## Architecture & Services

### Docker Infrastructure
- **Backend Container** (`mvp-store-backend`): Nginx + PHP-FPM (ports 8091, 8191)
- **PostgreSQL** (`mvp-store-backend-postgres-local`): Database on port 5441 (`store_backend` db)
- **Redis** (shared `mvp-store-redis`): Cache on port 6380
- **RabbitMQ** (shared `mvp-store-rabbitmq`): Message queue on ports 5680, 15680

### Microservices Communication
- **Payment Service**: Communicates via `PaymentClient` service
- **Network**: Uses external `mvp_store_network` Docker network for inter-service communication
- **Service Discovery**: Payment service accessible at `http://mvp-store-payment:8080`
- **Environment Variable**: `PAYMENT_SERVICE_URL="http://mvp-store-payment:8080"`

## Database Configuration

**Connection Details:**
- Host: localhost:5441 (external), postgres:5432 (internal container name)
- Database: `store_backend`
- User: `mvp_user`
- Password: `mvp_secret`

**Migration Workflow:**
1. Create entities or modify existing ones
2. Generate migration: `php bin/console doctrine:migrations:diff`
3. Apply migration: `php bin/console doctrine:migrations:migrate`

## Testing

**Test Execution:**
- `make test` - Run all tests from host
- `php bin/phpunit` - Run tests inside container
- Tests located in `tests/` directory
- PHPUnit configuration in `phpunit.dist.xml`

**Test Environment:**
- Uses `APP_ENV=test` environment
- Separate test database configuration
- Strict error reporting enabled

## Code Quality Tools

**PHP-CS-Fixer:**
- Setup: `make store-phpcs` (installs in `tools/php-cs-fixer/`)
- Run: `make fixer` to format code in `src/` directory

## Environment Configuration

**Environment Files:**
- `.env` - Default environment variables
- `.env.local` - Local overrides (gitignored)
- `.env.dev` - Development-specific settings
- `.env.test` - Test environment settings

**Key Environment Variables:**
- Database connection settings
- Redis configuration
- Payment service URL configuration

## Network Setup

**External Network:**
```bash
make network-create    # Create shared mvp_store_network
make network-remove    # Remove shared network
```

The `mvp_store_network` enables communication between backend and payment service containers.

## Service Health Monitoring

**Health Check Endpoints:**
- `/health` - Backend service health
- `/payment-service-health` - Cross-service communication test

**Usage Examples:**
```bash
curl http://localhost:8191/health                    # Backend health (direct)
curl http://localhost:8191/payment-service-health    # Payment communication test
curl http://localhost:8090/api/health                # Backend via API Gateway
```

These endpoints are useful for monitoring microservice connectivity and health status.
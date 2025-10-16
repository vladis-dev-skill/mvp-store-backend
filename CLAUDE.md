# CLAUDE.md - Backend Service

This file provides service-specific guidance to Claude Code when working with the MVP Store Backend service.

## Project Overview

**MVP Store Backend** is the main API service built with Symfony 7.3 (PHP 8.2+). It handles core business logic, user management, product catalog, orders, and orchestrates communication with the Payment Service.

**Role in Architecture**: Central API service that coordinates business operations and delegates payment processing to the dedicated Payment Service.

**Related Services**:
- Payment Service: `mvp-store-payment-service/` - Handles payment processing
- Frontend: `mvp-store-frontend/` - Next.js UI consuming this API
- Infrastructure: `mvp-store-infrastructure/` - API Gateway and shared services

For complete system architecture, see [Root CLAUDE.md](../CLAUDE.md).

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

## Environment Configuration

**Environment Files:**
- `.env` - Default environment variables
- `.env.local` - Local overrides (gitignored)
- `.env.dev` - Development-specific settings
- `.env.test` - Test environment settings

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

## Development Workflow

### Starting Development
```bash
# Option 1: Full system (with API Gateway)
cd ../mvp-store-infrastructure && make init
cd ../mvp-store-backend && make up

# Option 2: Local development (standalone)
cd mvp-store-backend && make up-local
```

## Key Directories

```
mvp-store-backend/
├── config/                    # Symfony configuration
│   ├── packages/             # Package-specific configs
│   ├── routes/               # Route definitions
│   └── services.yaml         # Service container config
├── docker/                   # Docker infrastructure
│   ├── docker-compose.yml   # Container orchestration
│   ├── Dockerfile           # Multi-stage build
│   ├── nginx/               # Web server config
│   ├── php-fpm/             # PHP-FPM config
│   └── supervisor/          # Process management
├── migrations/              # Database migrations
├── public/                  # Web root (index.php)
├── src/
├── tests/                  # PHPUnit tests
├── var/                    # Cache, logs (gitignored)
├── Makefile               # Development commands
└── composer.json          # PHP dependencies
```

## Claude Code Guidelines

When working on this service:
1. **Follow Symfony best practices** - Use framework conventions
2. **Maintain service isolation** - Backend should not know Payment Service implementation details
3. **Write tests** - Every new feature should have corresponding tests
4. **Document API changes** - Update documentation for new endpoints
5. **Use type hints** - PHP 8.2 supports full type declarations
6. **Handle errors gracefully** - Return appropriate HTTP status codes
7. **Log important events** - Use Symfony Logger for debugging
8. **Validate input** - Use Symfony Validator component
9. **Keep controllers thin** - Move business logic to services
10. **Review migrations** - Always check generated migrations before applying
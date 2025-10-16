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

## Development Workflow

### Starting Development
```bash
# Option 1: Full system (with API Gateway)
cd ../mvp-store-infrastructure && make init
cd ../mvp-store-backend && make up

# Option 2: Local development (standalone)
cd mvp-store-backend && make up-local
```

### Adding New API Endpoints
1. Create controller in `src/Controller/`
2. Define routes using PHP attributes: `#[Route('/api/endpoint', methods: ['GET'])]`
3. Add services/repositories in `src/Service/` or `src/Repository/`
4. Update API documentation if applicable
5. Write tests in `tests/`
6. Run `make fixer` to ensure code style compliance

### Working with Entities
1. Create/modify entity in `src/Entity/`
2. Generate migration: `php bin/console doctrine:migrations:diff`
3. Review generated migration file
4. Apply migration: `php bin/console doctrine:migrations:migrate`
5. Verify with: `php bin/console doctrine:schema:validate`

### Integrating with Payment Service
```php
// Use PaymentClient service for communication
use App\Service\PaymentClient;

public function __construct(
    private PaymentClient $paymentClient
) {}

// Example: Process payment
$result = $this->paymentClient->processPayment($paymentData);
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
│   ├── Controller/         # API endpoints
│   ├── Entity/             # Doctrine entities
│   ├── Repository/         # Database repositories
│   ├── Service/            # Business logic
│   └── Kernel.php          # Application kernel
├── tests/                  # PHPUnit tests
├── var/                    # Cache, logs (gitignored)
├── Makefile               # Development commands
└── composer.json          # PHP dependencies
```

## Important Symfony Concepts

### Service Container
- Services are auto-wired by default
- Configure services in `config/services.yaml`
- Use dependency injection for all dependencies

### Routing
- Use PHP attributes for routing (modern approach)
- Route prefix `/api` is configured for all API endpoints
- Example: `#[Route('/api/products', name: 'app_products', methods: ['GET'])]`

### Doctrine ORM
- Entities represent database tables
- Repositories handle database queries
- Use migrations for schema changes
- Never modify database schema manually

### Environment Management
- Development: `APP_ENV=dev`
- Production: `APP_ENV=prod`
- Testing: `APP_ENV=test`
- Use `.env.local` for local overrides

## Troubleshooting

### Common Issues

**Container won't start:**
```bash
make down && make up    # Restart containers
docker ps -a           # Check container status
make logs              # View container logs
```

**Database connection issues:**
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Test connection
docker exec -it mvp-store-backend-postgres-local psql -U mvp_user -d store_backend
```

**Payment service communication fails:**
```bash
# Verify network connectivity
docker network ls | grep mvp_store_network

# Check payment service is running
curl http://localhost:8192/api/health

# Test from backend container
make exec_bash
curl http://mvp-store-payment:8080/api/health
```

**Cache issues:**
```bash
# Clear Symfony cache
make exec_bash
php bin/console cache:clear
```

### Performance Tips
- Use Redis for caching frequently accessed data
- Implement repository query optimization
- Use Doctrine query profiler to identify slow queries
- Enable OpCache in production
- Use lazy loading for entity relationships

## Security Considerations

- Always validate and sanitize user input
- Use parameterized queries (Doctrine does this by default)
- Implement proper authentication/authorization
- Sanitize data before sending to Payment Service
- Never log sensitive data (passwords, payment details)
- Use HTTPS in production (configured via API Gateway)

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
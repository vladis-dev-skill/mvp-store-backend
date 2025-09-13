# MVP Store Backend

Symfony 7.3 backend service for MVP Store microservices architecture.

## Quick Setup

```bash
# Create shared network for microservices
make network-create

# Initialize and start project
make init

# Access application at http://localhost:8181
```

## Commands

```bash
make up          # Start containers
make down        # Stop containers  
make exec_bash   # Access PHP container
make test        # Run tests
```

## Services

- **Backend**: http://localhost:8181
- **Database**: localhost:5431 (PostgreSQL)
- **Redis**: localhost:6371

## Database Config

- Database: `store_backend`
- User: `store_user` 
- Password: `secret`

## Microservice Communication

Uses shared `mvp-store` Docker network to communicate with payment service at `http://store_payment_nginx`.
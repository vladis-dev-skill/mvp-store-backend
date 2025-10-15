# MVP Store Backend Service Commands

init: network-create docker-build up run-app
	@echo "Backend service initialized successfully!"
	@echo "Service available at: http://localhost:8191 (direct) or http://localhost:8090/api (via gateway)"

up:
	docker-compose -f docker/docker-compose.yml up -d

up-local:
	docker-compose -f docker/docker-compose.yml --profile local-dev up -d

down:
	docker-compose -f docker/docker-compose.yml down --remove-orphans

restart: down up

exec_bash:
	docker exec -it mvp-store-backend sh

test:
	@echo "Running backend tests..."
	docker exec -it mvp-store-backend php bin/phpunit

docker-build:
	docker-compose -f docker/docker-compose.yml build --no-cache

clean: down
	docker-compose -f docker/docker-compose.yml down -v --remove-orphans
	docker image rm mvp-store-backend_backend

# Application management
run-app: composer-install store-migrate

composer-install:
	docker exec -it mvp-store-backend composer install --optimize-autoloader

store-migrate:
	docker exec -it mvp-store-backend php bin/console doctrine:migrations:migrate --no-interaction

store-fixture:
	docker exec -it mvp-store-backend php bin/console doctrine:fixtures:load --no-interaction

fixer:
	@echo "Fixing code style..."
	docker exec -it mvp-store-backend tools/php-cs-fixer/vendor/bin/php-cs-fixer fix src

# Network management
network-create:
	@echo "Creating shared network..."
	@docker network create mvp_store_network || echo "Network already exists"

# Cache management
cache-clear:
	@echo "Clearing Symfony cache..."
	docker exec -it mvp-store-backend php bin/console cache:clear

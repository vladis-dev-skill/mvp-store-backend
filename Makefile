down: docker-down
up: docker-up
init: docker-down-clear docker-pull docker-build docker-up run-app
exec_bash: docker-exec-bash
test: store-test

store-test:
	docker exec -it store_backend_php-fpm php bin/phpunit

docker-up:
	docker-compose -p mvp-store-backend -f docker/docker-compose.yml up -d

docker-down:
	docker-compose -p mvp-store-backend -f docker/docker-compose.yml down --remove-orphans

docker-down-clear:
	docker-compose -p mvp-store-backend -f docker/docker-compose.yml down -v --remove-orphans

docker-pull:
	docker-compose -p mvp-store-backend -f docker/docker-compose.yml pull

docker-build:
	docker-compose -p mvp-store-backend -f docker/docker-compose.yml build

docker-exec-bash:
	docker exec -it store_backend_php-fpm bash

#Run app

run-app: composer-install store-migrate #store-fixture #store-phpcs

composer-install:
	docker exec -it store_backend_php-fpm composer install

store-migrate:
	docker exec -it store_backend_php-fpm php bin/console doctrine:migrations:migrate --no-interaction

store-fixture:
	docker exec -it store_backend_php-fpm php bin/console doctrine:fixtures:load --no-interaction

store-phpcs: store-phpcs-mkdir store-phpcs-composer
store-phpcs-mkdir:
	docker exec -it store_backend_php-fpm mkdir -p --parents tools/php-cs-fixer
store-phpcs-composer:
	docker exec -it store_backend_php-fpm composer require --no-interaction --working-dir=tools/php-cs-fixer friendsofphp/php-cs-fixer

fixer:
	docker exec -it store_backend_php-fpm tools/php-cs-fixer/vendor/bin/php-cs-fixer fix src

# Network management
network-create:
	docker network create mvp-store || true

network-remove:
	docker network rm mvp-store || true
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y unzip

RUN apt-get update && apt-get install -y libpq-dev zlib1g-dev libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql

RUN pecl install redis && docker-php-ext-enable redis

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer

WORKDIR /var/www/store

RUN curl -sS https://get.symfony.com/cli/installer | bash
# Multi-stage Dockerfile for MVP Store Backend
FROM php:8.2-fpm-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libxml2-dev \
    zip \
    unzip \
    postgresql-dev \
    oniguruma-dev \
    nginx \
    supervisor \
    autoconf \
    make \
    g++

# Install PHP extensions
RUN docker-php-ext-install \
    pdo \
    pdo_pgsql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    opcache

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create application user
RUN addgroup -g 1000 -S www && \
    adduser -u 1000 -S www -G www

# Set working directory
WORKDIR /var/www/store

# Copy application files
COPY --chown=www:www . .

# Install dependencies
USER www
RUN composer install --optimize-autoloader --no-interaction

# Switch back to root for configuration
USER root

# Configure PHP-FPM
COPY docker/php-fpm/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY docker/php-fpm/php.ini /usr/local/etc/php/php.ini

# Configure Nginx
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Configure Supervisor
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create necessary directories
RUN mkdir -p /var/log/supervisor /var/log/nginx /var/log/php-fpm && \
    chown -R www:www /var/www/store /var/log

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
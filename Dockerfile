FROM php:8.3-cli

ARG APP_ENV

ENV APP_ENV=${APP_ENV:-dev}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    git \
    curl \
    unzip \
    libzip-dev \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions including xdebug
RUN if [ "$APP_ENV" = "dev" ]; then \
    pecl install xdebug && docker-php-ext-enable xdebug \
        && docker-php-ext-install zip pdo pdo_pgsql; \
else \
    docker-php-ext-install zip pdo pdo_pgsql; \
fi

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy entrypoint and make executable
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy project files
COPY . .

# Install PHP dependencies
RUN composer install --no-progress --no-interaction --optimize-autoloader \
    && composer dump-autoload --optimize

# Create necessary directories
RUN mkdir -p var/cache var/log \
    && chmod -R 777 var/

# Configure XDebug
RUN if [ "$APP_ENV" = "dev" ]; then \
    echo "xdebug.mode=debug\nxdebug.start_with_request=yes\nxdebug.client_host=host.docker.internal\nxdebug.client_port=9003\nxdebug.log=/tmp/xdebug.log" > /usr/local/etc/php/conf.d/xdebug.ini; \
fi

# Expose ports
EXPOSE 80 9003

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Use entrypoint for DB initialization; then run PHP built-in server with Symfony router
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php", "-S", "0.0.0.0:80", "-t", "public", "public/index.php"]

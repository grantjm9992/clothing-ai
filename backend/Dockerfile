FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_pgsql pgsql mbstring exif pcntl bcmath gd

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy all application files
COPY . /var/www

# Debug: Show composer.json exists
RUN echo "=== Checking composer.json ===" && ls -la composer.json

# Install dependencies without running scripts
RUN echo "=== Running composer install ===" \
    && composer install --no-scripts --no-interaction --no-dev --prefer-dist --ignore-platform-reqs \
    && echo "=== Composer install completed ==="

# Create vendor/autoload.php manually
RUN echo "=== Running composer dump-autoload ===" \
    && composer dump-autoload --no-scripts --optimize --ignore-platform-reqs \
    && echo "=== Dump-autoload completed ==="

# Debug: Show vendor directory
RUN echo "=== Checking vendor directory ===" && ls -la vendor/ | head -20

# Verify vendor/autoload.php exists
RUN test -f /var/www/vendor/autoload.php && echo "SUCCESS: vendor/autoload.php exists!" || (echo "ERROR: vendor/autoload.php not created!" && exit 1)

# Create storage directories
RUN mkdir -p /var/www/storage/app/public \
    && mkdir -p /var/www/storage/framework/cache/data \
    && mkdir -p /var/www/storage/framework/sessions \
    && mkdir -p /var/www/storage/framework/views \
    && mkdir -p /var/www/storage/logs \
    && mkdir -p /var/www/bootstrap/cache

# Set permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 /var/www/storage \
    && chmod -R 755 /var/www/bootstrap/cache

# Change current user to www-data
USER www-data

# Expose port 8000
EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]

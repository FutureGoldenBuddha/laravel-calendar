FROM php:8.2-fpm

# ── System dependencies ───────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    git \
    openssh-client \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── PHP extensions ────────────────────────────────────────────────────────────
RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    zip

# ── Composer ──────────────────────────────────────────────────────────────────
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ── 1. Create a fresh Laravel project in /tmp, then move to /var/www ─────────
#    (composer refuses to install into a non-empty directory, and the base
#     php-fpm image already has content in /var/www)
RUN composer create-project laravel/laravel /tmp/laravel --prefer-dist --no-interaction \
    && cp -r /tmp/laravel/. /var/www/ \
    && rm -rf /tmp/laravel

COPY .devcontainer/setup.sh /tmp

# ── 2. Overlay our custom template files ─────────────────────────────────────
WORKDIR /var/www
COPY . .

# ── 3. Permissions ────────────────────────────────────────────────────────────
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

EXPOSE 9000
CMD ["php-fpm"]

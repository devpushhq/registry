# syntax=docker/dockerfile:1

# Use a separate stage to get the correct Caddy binary for the architecture.
FROM caddy:2-alpine AS caddy_bin

FROM php:8.3-fpm-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# System deps + PHP extensions.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        unzip \
        zip \
        libicu-dev \
        libonig-dev \
        libpng-dev \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        libpq-dev \
        libzip-dev \
        gosu \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath gd intl mbstring opcache pcntl pdo pdo_mysql pdo_pgsql zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Caddy (handles arm64/amd64 automatically)
COPY --from=caddy_bin /usr/bin/caddy /usr/bin/caddy

# Ensure php-fpm is available on PATH even if PATH is overridden at runtime.
RUN ln -sf /usr/local/sbin/php-fpm /usr/local/bin/php-fpm

# Create default non-root user (will be remapped at runtime by entrypoint).
RUN set -eu; \
    if ! getent group appgroup >/dev/null; then \
        groupadd --system appgroup; \
    fi; \
    if ! id -u appuser >/dev/null 2>&1; then \
        useradd -m -u 1000 -g appgroup -o -s /bin/bash appuser; \
    fi

# Configure PHP-FPM defaults.
RUN printf '%s\n' \
      '[www]' \
      'user = appuser' \
      'group = appgroup' \
      'listen = 127.0.0.1:9000' \
      'access.log = /tmp/php-fpm-access.log' \
      'clear_env = no' \
    > /usr/local/etc/php-fpm.d/zz-devpush.conf && \
    printf '%s\n' \
      '[global]' \
      'pid = /tmp/php-fpm.pid' \
      'error_log = /tmp/php-fpm-error.log' \
    > /usr/local/etc/php-fpm.d/zz-devpush-global.conf

# Default Caddy config.
RUN install -d -m 0755 /etc/caddy && \
    printf '%s\n' \
      ':8000' \
      'root * /app/public' \
      'encode zstd gzip' \
      'php_fastcgi 127.0.0.1:9000' \
      'file_server' \
    > /etc/caddy/Caddyfile

COPY runners/_common/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /app

ENV HOME=/home/appuser
ENV COMPOSER_CACHE_DIR=/cache/composer

ENTRYPOINT ["/entrypoint.sh"]

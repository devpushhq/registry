# syntax=docker/dockerfile:1

FROM dunglas/frankenphp:1-php8.3

ENV DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE

# Remove app/data directories created by the upstream image. DevPush binds `/app`
# from the host, and we keep runtime state out of `/data`.
RUN rm -rf /app /data

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

RUN set -eu; \
    if ! getent group appgroup >/dev/null; then \
        groupadd --system appgroup; \
    fi; \
    if ! id -u appuser >/dev/null 2>&1; then \
        useradd -m -u 1000 -g appgroup -o -s /bin/bash appuser; \
    fi

# Default Caddy config (Laravel-style).
RUN install -d -m 0755 /etc/caddy && \
    cat > /etc/caddy/Caddyfile <<'EOF'
{
  admin off
}
:8000 {
  root * /app/public
  encode zstd gzip
  php_server
}
EOF

COPY runners/_common/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /app

ENV HOME=/home/appuser
ENV XDG_DATA_HOME=/tmp XDG_CONFIG_HOME=/tmp
ENV COMPOSER_CACHE_DIR=/cache/composer

ENTRYPOINT ["/entrypoint.sh"]

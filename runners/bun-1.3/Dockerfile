# syntax=docker/dockerfile:1

FROM oven/bun:1.3-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        gosu \
    && rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    if ! getent group appgroup >/dev/null; then \
        groupadd --system appgroup; \
    fi; \
    if ! id -u appuser >/dev/null 2>&1; then \
        useradd -m -u 1000 -g appgroup -o -s /bin/bash appuser; \
    fi

COPY runners/_common/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /app

ENV BUN_INSTALL=/cache/bun
ENV NPM_CONFIG_CACHE=/cache/npm
ENV NPM_CONFIG_PREFIX=/cache/npm-prefix
ENV PATH=/cache/bun/bin:/cache/npm-prefix/bin:$PATH
ENV HOME=/home/appuser

ENTRYPOINT ["/entrypoint.sh"]

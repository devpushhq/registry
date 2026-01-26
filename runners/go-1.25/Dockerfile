# syntax=docker/dockerfile:1

FROM golang:1.25-bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        make \
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

ENV GOPATH=/cache/go
ENV GOCACHE=/cache/go-build
ENV GOMODCACHE=/cache/go-mod
ENV PATH=/cache/go/bin:$PATH
ENV HOME=/home/appuser

ENTRYPOINT ["/entrypoint.sh"]

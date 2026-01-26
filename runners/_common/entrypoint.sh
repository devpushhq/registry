#!/usr/bin/env bash
set -Eeuo pipefail

# Runner images start as root so we can map the runtime user/group IDs to the
# host service UID/GID. We then drop privileges and exec the given command.

APP_USER="${APP_USER:-appuser}"
APP_GROUP="${APP_GROUP:-appgroup}"

PUID="${PUID:-}"
PGID="${PGID:-}"

if [[ $# -eq 0 ]]; then
  printf "entrypoint: no command provided\n" >&2
  exit 2
fi

if [[ "$(id -u)" -ne 0 ]]; then
  exec "$@"
fi

run_user="$APP_USER"
run_group="$APP_GROUP"

if [[ -n "$PGID" ]]; then
  existing_group="$(getent group "$PGID" | cut -d: -f1 || true)"
  if [[ -n "$existing_group" ]]; then
    run_group="$existing_group"
  else
    groupmod -g "$PGID" "$APP_GROUP" 2>/dev/null || groupadd -g "$PGID" "$APP_GROUP"
  fi
fi

if [[ -n "$PUID" ]]; then
  # Allow non-unique IDs: some base images already contain UID 1000 (e.g. `node`).
  usermod -o -u "$PUID" -g "$run_group" "$APP_USER" 2>/dev/null || true
else
  usermod -g "$run_group" "$APP_USER" 2>/dev/null || true
fi

install -d -m 0755 -o "$APP_USER" -g "$run_group" "/home/$APP_USER" /app /cache

# Avoid failing startup just because ownership can't be changed on certain mounts.
chown -R "$APP_USER:$run_group" "/home/$APP_USER" /app /cache 2>/dev/null || true

exec gosu "$run_user" "$@"

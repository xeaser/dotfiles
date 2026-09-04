#!/usr/bin/env bash
set -euo pipefail

# Recreate the laptop-side Twingate connector container.
# Faithful to the OLD Mac: twingate/connector:latest, bridge network,
# restart=unless-stopped, no caps/sysctls/devices. Tokens from ~/.secrets.

SECRETS="$HOME/.secrets"
[ -f "$SECRETS" ] || { echo "FATAL: $SECRETS not found"; exit 1; }
# shellcheck disable=SC1090
source "$SECRETS"

: "${TWINGATE_NETWORK:?missing TWINGATE_NETWORK in ~/.secrets}"
: "${TWINGATE_ACCESS_TOKEN:?missing TWINGATE_ACCESS_TOKEN in ~/.secrets}"
: "${TWINGATE_REFRESH_TOKEN:?missing TWINGATE_REFRESH_TOKEN in ~/.secrets}"

docker info >/dev/null 2>&1 || { echo "FATAL: Docker not running (start Docker Desktop first)"; exit 1; }

echo "Pulling twingate/connector:latest ..."
docker pull twingate/connector:latest

echo "Recreating twingate-connector ..."
docker rm -f twingate-connector >/dev/null 2>&1 || true
docker run -d \
  --name twingate-connector \
  --restart unless-stopped \
  --env TWINGATE_NETWORK \
  --env TWINGATE_ACCESS_TOKEN \
  --env TWINGATE_REFRESH_TOKEN \
  twingate/connector:latest

docker ps --filter name=twingate-connector --format '  {{.Names}}  {{.Status}}'

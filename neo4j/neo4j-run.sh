#!/usr/bin/env bash
set -euo pipefail

# Recreate the local neo4j container (codegraph backend).
# NEO4J_AUTH comes from ~/.secrets (format: neo4j/<password>). Fresh named
# volumes (neo4j-data / neo4j-logs) — re-index via codegraph as needed.
# Run in a GUI Terminal (Docker registry auth needs the login keychain).

SECRETS="$HOME/.secrets"
[ -f "$SECRETS" ] || { echo "FATAL: $SECRETS not found"; exit 1; }
# shellcheck disable=SC1090
source "$SECRETS"

: "${NEO4J_AUTH:?missing NEO4J_AUTH in ~/.secrets (format neo4j/password)}"

docker info >/dev/null 2>&1 || { echo "FATAL: Docker not running (start Docker Desktop first)"; exit 1; }

echo "Pulling neo4j:latest ..."
docker pull neo4j:latest

echo "Recreating neo4j ..."
docker rm -f neo4j >/dev/null 2>&1 || true
docker run -d \
  --name neo4j \
  --restart unless-stopped \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH \
  -v neo4j-data:/data \
  -v neo4j-logs:/logs \
  neo4j:latest

docker ps --filter name=neo4j --format '  {{.Names}}  {{.Status}}'

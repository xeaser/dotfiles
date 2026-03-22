#!/bin/bash
set -euo pipefail

NEO4J_CONTAINER="neo4j"
NEO4J_BOLT_PORT=7687
NEO4J_HTTP_PORT=7474
MAX_WAIT=60

ensure_neo4j() {
  if docker ps --format '{{.Names}}' | grep -q "^${NEO4J_CONTAINER}$"; then
    wait_for_ready
    return 0
  fi

  if docker ps -a --format '{{.Names}}' | grep -q "^${NEO4J_CONTAINER}$"; then
    docker start "${NEO4J_CONTAINER}" >/dev/null 2>&1
  else
    docker run -d --name "${NEO4J_CONTAINER}" \
      -p "${NEO4J_HTTP_PORT}:7474" \
      -p "${NEO4J_BOLT_PORT}:7687" \
      -e "NEO4J_AUTH=neo4j/${NEO4J_PASSWORD:-password}" \
      neo4j:latest >/dev/null 2>&1
  fi

  wait_for_ready
}

wait_for_ready() {
  for i in $(seq 1 "${MAX_WAIT}"); do
    if curl -sf "http://localhost:${NEO4J_HTTP_PORT}" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "ERROR: Neo4j failed to become ready within ${MAX_WAIT}s" >&2
  return 1
}

ensure_neo4j
exec cgc mcp start

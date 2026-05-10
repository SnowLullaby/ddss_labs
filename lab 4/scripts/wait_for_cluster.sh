#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-127.0.0.1}"
PORT="${2:-9042}"
MAX_ATTEMPTS="${MAX_ATTEMPTS:-90}"

printf '[wait] Waiting for cqlsh on %s:%s\n' "$HOST" "$PORT"
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  if cqlsh "$HOST" "$PORT" -e 'DESCRIBE KEYSPACES' >/dev/null 2>&1; then
    echo '[wait] cqlsh is ready.'
    break
  fi
  if [ "$attempt" -eq "$MAX_ATTEMPTS" ]; then
    echo '[wait] ERROR: cqlsh is not ready.' >&2
    exit 1
  fi
  sleep 5
done

printf '[wait] Waiting for three UN nodes in nodetool status\n'
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  STATUS="$(nodetool status 2>/dev/null || true)"
  UN_COUNT="$(printf '%s\n' "$STATUS" | awk '$1 == "UN" {count++} END {print count + 0}')"
  if [ "$UN_COUNT" -ge 3 ]; then
    echo '[wait] Cluster is ready:'
    nodetool status
    exit 0
  fi
  if [ "$attempt" -eq "$MAX_ATTEMPTS" ]; then
    echo '[wait] ERROR: expected 3 UN nodes, got:' >&2
    printf '%s\n' "$STATUS" >&2
    exit 1
  fi
  sleep 5
done

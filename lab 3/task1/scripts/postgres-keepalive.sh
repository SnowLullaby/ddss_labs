#!/usr/bin/env bash
set -euo pipefail

child_pid=""

shutdown() {
  if [ -n "${child_pid}" ] && kill -0 "$child_pid" 2>/dev/null; then
    kill -TERM "$child_pid" 2>/dev/null || true
    wait "$child_pid" || true
  fi
  exit 0
}

trap shutdown SIGTERM SIGINT

/usr/local/bin/docker-entrypoint.sh "$@" &
child_pid=$!

wait "$child_pid" || true

while true; do
  sleep 3600
done
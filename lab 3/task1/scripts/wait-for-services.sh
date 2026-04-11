#!/usr/bin/env bash
set -euo pipefail

while [ "$#" -gt 0 ]; do
  host="$1"
  port="$2"
  shift 2
  echo "[wait] ${host}:${port}"
  until pg_isready -h "$host" -p "$port" -U postgres -d postgres >/dev/null 2>&1; do
    sleep 2
  done
done

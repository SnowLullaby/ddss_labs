#!/usr/bin/env bash
set -euo pipefail

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
FILL_FILE="${FILL_FILE:-$PGDATA/.diskfill.bin}"
RESERVE_KB="${RESERVE_KB:-0}"

printf '== Disk usage before fill ==\n'
df -h "$PGDATA"

rm -f "$FILL_FILE"

available_kb=$(df -Pk "$PGDATA" | awk 'NR==2 {print $4}')
target_kb=$((available_kb - RESERVE_KB))

if [ "$target_kb" -le 0 ]; then
  echo "Not enough free space to fill"
  exit 0
fi

echo "Filling ${target_kb} KB in $FILL_FILE"

if command -v fallocate >/dev/null 2>&1; then
  set +e
  fallocate -l "${target_kb}K" "$FILL_FILE"
  rc=$?
  set -e
  if [ "$rc" -ne 0 ]; then
    dd if=/dev/zero of="$FILL_FILE" bs=1K count="$target_kb" status=progress
  fi
else
  dd if=/dev/zero of="$FILL_FILE" bs=1K count="$target_kb" status=progress
fi

sync || true

printf '== Disk usage after fill ==\n'
df -h "$PGDATA"
ls -lh "$FILL_FILE" || true

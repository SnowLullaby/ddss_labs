#!/usr/bin/env bash
set -euo pipefail

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
FILL_FILE="${FILL_FILE:-$PGDATA/.diskfill.bin}"

rm -f "$FILL_FILE"
sync || true

echo '== Disk usage after cleanup =='
df -h "$PGDATA"

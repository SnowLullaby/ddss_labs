#!/usr/bin/env bash
set -euo pipefail

FAILED_NODE_ID="$1"
OLD_PRIMARY_NODE_ID="$2"
NEW_MAIN_NODE_ID="$3"
NEW_MAIN_HOST="$4"
OLD_MAIN_NODE_ID="$5"
OLD_PRIMARY_HOST="${6:-}"

echo "[failover] failed_node_id=${FAILED_NODE_ID} old_primary_node_id=${OLD_PRIMARY_NODE_ID} new_main_node_id=${NEW_MAIN_NODE_ID} new_main_host=${NEW_MAIN_HOST} old_primary_host=${OLD_PRIMARY_HOST}"

# Если упал не primary
if [ "$FAILED_NODE_ID" != "$OLD_PRIMARY_NODE_ID" ]; then
  echo "[failover] failed node is not old primary, nothing to promote"
  exit 0
fi

# Если pgpool не нашел живого кандидата
if [ "$NEW_MAIN_NODE_ID" = "-1" ] || [ -z "${NEW_MAIN_HOST}" ]; then
  echo "[failover] no candidate standby available"
  exit 1
fi

export PGPASSWORD=postgres

psql -v ON_ERROR_STOP=1 \
  -h "$NEW_MAIN_HOST" \
  -p 5432 \
  -U postgres \
  -d postgres \
  -c "SELECT pg_promote();"

until psql -tAc "select not pg_is_in_recovery()" \
  -h "$NEW_MAIN_HOST" \
  -p 5432 \
  -U postgres \
  -d postgres | grep -qx t; do
  sleep 1
done

echo "[failover] promoted ${NEW_MAIN_HOST} to primary"
exit 0

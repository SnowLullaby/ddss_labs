#!/usr/bin/env bash
set -euo pipefail

PRIMARY_HOST="${PRIMARY_HOST:?PRIMARY_HOST is required}"
REPLICATION_SLOT="${REPLICATION_SLOT:-}"
STANDBY_NAME="${STANDBY_NAME:?STANDBY_NAME is required}"
APPLY_DELAY="${APPLY_DELAY:-0s}"
PGDATA="${PGDATA:-/var/lib/postgresql/data}"

echo "[rejoin] PRIMARY_HOST=${PRIMARY_HOST}"
echo "[rejoin] STANDBY_NAME=${STANDBY_NAME}"
echo "[rejoin] REPLICATION_SLOT=${REPLICATION_SLOT:-<none>}"
echo "[rejoin] APPLY_DELAY=${APPLY_DELAY}"

if pg_ctl -D "$PGDATA" status >/dev/null 2>&1; then
  echo "[rejoin] stopping local postgres"
  pg_ctl -D "$PGDATA" -w stop -m fast
fi

rm -f "$PGDATA/postmaster.pid" 2>/dev/null || true

export PGPASSWORD=postgres

echo "[rejoin] running pg_rewind from ${PRIMARY_HOST}"
pg_rewind \
  --target-pgdata="$PGDATA" \
  --source-server="host=${PRIMARY_HOST} port=5432 user=postgres password=postgres dbname=postgres"

touch "$PGDATA/standby.signal"
rm -f "$PGDATA/recovery.signal"

if [ ! -f "$PGDATA/postgresql.auto.conf" ]; then
  touch "$PGDATA/postgresql.auto.conf"
fi

sed -i \
  -e '/^primary_conninfo =/d' \
  -e '/^primary_slot_name =/d' \
  -e '/^recovery_min_apply_delay =/d' \
  "$PGDATA/postgresql.auto.conf"

{
  echo "primary_conninfo = 'host=${PRIMARY_HOST} port=5432 user=replicator password=replicator application_name=${STANDBY_NAME}'"
  if [ -n "$REPLICATION_SLOT" ]; then
    echo "primary_slot_name = '${REPLICATION_SLOT}'"
  fi
  echo "recovery_min_apply_delay = '${APPLY_DELAY}'"
} >> "$PGDATA/postgresql.auto.conf"

cp /etc/postgresql/custom/postgresql.conf "$PGDATA/postgresql.conf"
cp /etc/postgresql/custom/pg_hba.conf "$PGDATA/pg_hba.conf"

echo "[rejoin] starting postgres as standby"
pg_ctl -D "$PGDATA" -w start -o "-c config_file=$PGDATA/postgresql.conf -c hba_file=$PGDATA/pg_hba.conf"

until psql -tAc "select pg_is_in_recovery()" -U postgres -d postgres | grep -qx t; do
  sleep 1
done

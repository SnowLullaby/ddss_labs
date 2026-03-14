#!/bin/sh
set -eu

PGPORT=9437
RECOVERY_DIR="$HOME/recovery"

mkdir -p "$RECOVERY_DIR"

pg_dump \
  -p "$PGPORT" \
  -d longpinksoup \
  --data-only \
  --column-inserts \
  --disable-triggers \
  -t public.client \
  -t public.pay \
  > "$RECOVERY_DIR/longpinksoup_data.sql"

psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS client_dump_source FROM public.client;"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS pay_dump_source FROM public.pay;"
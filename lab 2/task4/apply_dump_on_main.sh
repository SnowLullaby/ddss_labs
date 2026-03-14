#!/bin/sh
set -eu

PGPORT=9437
RESERVE="postgres1@pg155"
RECOVERY_DIR="$HOME/recovery"

mkdir -p "$RECOVERY_DIR"

scp "$RESERVE:$HOME/recovery/longpinksoup_data.sql" "$RECOVERY_DIR/longpinksoup_data.sql"

psql -p "$PGPORT" -d longpinksoup -c "TRUNCATE TABLE public.pay, public.client RESTART IDENTITY CASCADE;"
psql -X -v ON_ERROR_STOP=1 -p "$PGPORT" -d longpinksoup -f "$RECOVERY_DIR/longpinksoup_data.sql"
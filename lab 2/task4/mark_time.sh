#!/bin/sh
set -eu

PGPORT=9437
RESERVE="postgres1@pg155"
RECOVERY_DIR="$HOME/recovery"

mkdir -p "$RECOVERY_DIR"
ssh "$RESERVE" "mkdir -p $HOME/recovery"

TARGET_TIME=$(psql -p "$PGPORT" -d postgres -tA -c "SELECT to_char(clock_timestamp(), 'YYYY-MM-DD HH24:MI:SSOF');")
printf '%s\n' "$TARGET_TIME" > "$RECOVERY_DIR/recovery_target_time.txt"

scp "$RECOVERY_DIR/recovery_target_time.txt" "$RESERVE:$HOME/recovery/recovery_target_time.txt"

echo "Recovery target time: $TARGET_TIME"

psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS client_before_delete FROM public.client;"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS pay_before_delete FROM public.pay;"
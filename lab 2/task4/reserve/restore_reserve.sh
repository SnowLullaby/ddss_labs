#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
PGPORT=9437
BACKUP_ROOT="$HOME/lr2_backups/base"
WAL_ARCHIVE="$HOME/lr2_backups/wal"
RECOVERY_DIR="$HOME/recovery"

mkdir -p "$RECOVERY_DIR"

LATEST_BACKUP=$(ls -dt "$BACKUP_ROOT"/base_* | head -1)
TARGET_TIME=$(cat "$RECOVERY_DIR/recovery_target_time.txt")

pg_ctl -D "$PGDATA" stop -m fast 2>/dev/null || true
rm -rf "$PGDATA"
mkdir -p "$PGDATA"
chmod 700 "$PGDATA"

tar -xzf "$LATEST_BACKUP/base.tar.gz" -C "$PGDATA"
chmod 700 "$PGDATA"

if [ -f "$PGDATA/tablespace_map" ]; then
    while read -r OID TSPATH; do
        rm -rf "$TSPATH"
        mkdir -p "$TSPATH"
        chmod 700 "$TSPATH"
        tar -xzf "$LATEST_BACKUP/$OID.tar.gz" -C "$TSPATH"
    done < "$PGDATA/tablespace_map"
fi

cat >> "$PGDATA/postgresql.conf" <<EOF
restore_command = 'cp $WAL_ARCHIVE/%f %p'
recovery_target_time = '$TARGET_TIME'
recovery_target_inclusive = true
recovery_target_timeline = 'latest'
recovery_target_action = 'promote'
port = $PGPORT
EOF

rm -f "$PGDATA/recovery.signal" "$PGDATA/standby.signal"
touch "$PGDATA/recovery.signal"

pg_ctl -D "$PGDATA" -l "$PGDATA/recovery.log" start
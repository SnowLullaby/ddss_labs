#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
PGPORT=9437
BACKUP_ROOT="$HOME/lr2_backups/base"
WAL_ARCHIVE="$HOME/lr2_backups/wal"

LATEST_BACKUP=$(ls -dt "$BACKUP_ROOT"/base_* | head -1)

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
        chmod 700 "$TSPATH"
    done < "$PGDATA/tablespace_map"
fi

cat >> "$PGDATA/postgresql.conf" <<EOF
restore_command = 'cp $WAL_ARCHIVE/%f %p'
port = $PGPORT
EOF

rm -f "$PGDATA/recovery.signal" "$PGDATA/standby.signal"
touch "$PGDATA/standby.signal"

pg_ctl -D "$PGDATA" -l "$PGDATA/server.log" start
pg_ctl -D "$PGDATA" promote -W
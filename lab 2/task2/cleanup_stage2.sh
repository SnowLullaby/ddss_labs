#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
BACKUP_ROOT="$HOME/lr2_backups/base"

LATEST_BACKUP=$(ls -dt "$BACKUP_ROOT"/base_* | head -1)

pg_ctl -D "$PGDATA" stop -m fast 2>/dev/null || true

if [ -f "$PGDATA/tablespace_map" ]; then
    while read -r OID TSPATH; do
        rm -rf "$TSPATH"
    done < "$PGDATA/tablespace_map"
elif [ -f "$LATEST_BACKUP/base.tar.gz" ]; then
    TMPDIR=$(mktemp -d)
    tar -xzf "$LATEST_BACKUP/base.tar.gz" -C "$TMPDIR" tablespace_map 2>/dev/null || true
    if [ -f "$TMPDIR/tablespace_map" ]; then
        while read -r OID TSPATH; do
            rm -rf "$TSPATH"
        done < "$TMPDIR/tablespace_map"
    fi
    rm -rf "$TMPDIR"
fi

rm -rf "$PGDATA"
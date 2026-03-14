#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
PGPORT=9437

RESERVE="postgres1@pg155"
REMOTE_BASE_ROOT="~/lr2_backups/base"
REMOTE_WAL_ROOT="~/lr2_backups/wal"

RESTORE_ROOT="$HOME/restore"
LOCAL_BASE_ROOT="$RESTORE_ROOT/base"
LOCAL_WAL_ROOT="$RESTORE_ROOT/wal"
NEW_TBLSPC_ROOT="$HOME/restore/tablespaces"

mkdir -p "$RESTORE_ROOT"
rm -rf "$LOCAL_BASE_ROOT" "$LOCAL_WAL_ROOT" "$NEW_TBLSPC_ROOT"
mkdir -p "$LOCAL_BASE_ROOT" "$LOCAL_WAL_ROOT" "$NEW_TBLSPC_ROOT"

LATEST_REMOTE_BACKUP=$(ssh "$RESERVE" "ls -dt $REMOTE_BASE_ROOT/base_* | head -1")
scp -r "$RESERVE:$LATEST_REMOTE_BACKUP" "$LOCAL_BASE_ROOT/"
scp -r "$RESERVE:$REMOTE_WAL_ROOT/." "$LOCAL_WAL_ROOT/"

LATEST_LOCAL_BACKUP=$(ls -dt "$LOCAL_BASE_ROOT"/base_* | head -1)

pg_ctl -D "$PGDATA" stop -m fast 2>/dev/null || true
rm -rf "$PGDATA"
mkdir -p "$PGDATA"
chmod 700 "$PGDATA"

tar -xzf "$LATEST_LOCAL_BACKUP/base.tar.gz" -C "$PGDATA"
chmod 700 "$PGDATA"

if [ -f "$PGDATA/tablespace_map" ]; then
    TMPMAP="$PGDATA/tablespace_map.new"
    : > "$TMPMAP"

    while read -r OID OLDPATH; do
        NEWPATH="$NEW_TBLSPC_ROOT/$(basename "$OLDPATH")"
        mkdir -p "$NEWPATH"
        chmod 700 "$NEWPATH"

        echo "$OID $NEWPATH" >> "$TMPMAP"
        tar -xzf "$LATEST_LOCAL_BACKUP/$OID.tar.gz" -C "$NEWPATH"
    done < "$PGDATA/tablespace_map"

    mv "$TMPMAP" "$PGDATA/tablespace_map"
fi

cat >> "$PGDATA/postgresql.conf" <<EOF
restore_command = 'cp $LOCAL_WAL_ROOT/%f %p'
port = $PGPORT
EOF

touch "$PGDATA/recovery.signal"

pg_ctl -D "$PGDATA" -l "$PGDATA/recovery.log" start
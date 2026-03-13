#!/bin/sh

PGPORT=9437
STAMP=$(date +%F_%H-%M-%S)
LOCAL="$HOME/lr2_backups/base/base_$STAMP"
REMOTE="postgres1@pg155"
REMOTE_BASE="~/lr2_backups/base"

mkdir -p "$LOCAL"

pg_basebackup -p "$PGPORT" -U postgres1 -D "$LOCAL" -Ft -z -X none -P

ssh "$REMOTE" "mkdir -p $REMOTE_BASE"
scp -r "$LOCAL" "$REMOTE:$REMOTE_BASE/"
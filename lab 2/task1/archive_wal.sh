#!/bin/sh

REMOTE="postgres1@pg155"
DST="~/lr2_backups/wal"

ssh "$REMOTE" "mkdir -p $DST"
ssh "$REMOTE" "test -f $DST/$2" && exit 0
scp "$1" "$REMOTE:$DST/$2"
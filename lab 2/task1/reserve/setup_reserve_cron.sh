#!/bin/sh

TASKDIR="$HOME/lr2/task1"

TMP_CRON="$(mktemp)"

crontab -l 2>/dev/null > "$TMP_CRON" || true

grep -Fqx "15 2 * * * $TASKDIR/cleanup_reserve.sh >> $TASKDIR/cleanup_reserve.log 2>&1" "$TMP_CRON" || \
echo "15 2 * * * $TASKDIR/cleanup_reserve.sh >> $TASKDIR/cleanup_reserve.log 2>&1" >> "$TMP_CRON"

crontab "$TMP_CRON"
rm -f "$TMP_CRON"
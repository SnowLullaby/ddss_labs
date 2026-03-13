#!/bin/sh

PGDATA="$HOME/ejl64"
TASKDIR="$HOME/lr2/task1"

# postgresql.conf
echo "wal_level = replica" >> "$PGDATA/postgresql.conf" 
echo "archive_mode = on" >> "$PGDATA/postgresql.conf" 
echo "archive_command = '$TASKDIR/archive_wal.sh \"%p\" \"%f\"'" >> "$PGDATA/postgresql.conf" 
echo "archive_timeout = '5min'" >> "$PGDATA/postgresql.conf" 
echo "max_wal_senders = 4" >> "$PGDATA/postgresql.conf" 

# pg_hba.conf
echo "local   replication   postgres1   peer" >> "$PGDATA/pg_hba.conf" 

# cron
TMP_CRON="$(mktemp)"

crontab -l 2>/dev/null > "$TMP_CRON" || true

grep -Fqx '0 2 * * 0 /home/postgres1/lr2/task1/basebackup.sh >> /home/postgres1/lr2/task1/basebackup.log 2>&1' "$TMP_CRON" || \
echo '0 2 * * 0 /home/postgres1/lr2/task1/basebackup.sh >> /home/postgres1/lr2/task1/basebackup.log 2>&1' >> "$TMP_CRON"

grep -Fqx '15 2 * * * /home/postgres1/lr2/task1/cleanup.sh >> /home/postgres1/lr2/task1/cleanup.log 2>&1' "$TMP_CRON" || \
echo '15 2 * * * /home/postgres1/lr2/task1/cleanup.sh >> /home/postgres1/lr2/task1/cleanup.log 2>&1' >> "$TMP_CRON"

crontab "$TMP_CRON"
rm -f "$TMP_CRON"
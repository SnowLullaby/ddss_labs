#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
PGPORT=9437

RESERVE="postgres1@pg155"

LR1="$HOME/lr1"
TASK1_DIR="$HOME/lr2/task1"
TASK3_DIR="$HOME/lr2/task3"

LOCAL_BACKUP_ROOT="$HOME/lr2_backups"
LOCAL_BASE_ROOT="$LOCAL_BACKUP_ROOT/base"

REMOTE_BACKUP_ROOT="~/lr2_backups"
REMOTE_BASE_ROOT="~/lr2_backups/base"
REMOTE_WAL_ROOT="~/lr2_backups/wal"

"$LR1/clean.sh"

rm -rf "$LOCAL_BACKUP_ROOT"
mkdir -p "$LOCAL_BASE_ROOT"
ssh "$RESERVE" "rm -rf $REMOTE_BACKUP_ROOT && mkdir -p $REMOTE_BASE_ROOT $REMOTE_WAL_ROOT"

"$LR1/init.sh"

"$LR1/configurate.sh"
"$TASK1_DIR/setup_backup_conf.sh"

"$LR1/start.sh"
"$LR1/tablespaces.sh"
"$LR1/create.sh"
"$LR1/role.sh"

cd $LR1
"./fill.sh"
"./list.sh"
cd $HOME

"$TASK1_DIR/tests_wal.sh"
"$TASK1_DIR/basebackup.sh"
"$TASK1_DIR/tests_basebackup.sh"

echo "Чистое состояние собрано"
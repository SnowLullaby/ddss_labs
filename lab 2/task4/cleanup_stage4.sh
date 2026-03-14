#!/bin/sh
set -eu

RESERVE="postgres1@pg155"
RECOVERY_DIR="$HOME/recovery"

ssh "$RESERVE" '
set -eu
mkdir -p "$HOME/recovery"
"$HOME/lr2/task2/cleanup_stage2.sh"
rm -f "$HOME/recovery/recovery_target_time.txt"
rm -f "$HOME/recovery/longpinksoup_data.sql"
rm -rf "$HOME/recovery/"
'

mkdir -p "$RECOVERY_DIR"
rm -f "$RECOVERY_DIR/recovery_target_time.txt"
rm -f "$RECOVERY_DIR/longpinksoup_data.sql"
rm -rf "$RECOVERY_DIR"
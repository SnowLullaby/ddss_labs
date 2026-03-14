#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"

RESTORE_ROOT1="$HOME/restore"
TBLSPC_ROOT1="$HOME/restore/tablespaces"

pg_ctl -D "$PGDATA" stop -m fast 2>/dev/null || true

rm -rf "$PGDATA"
rm -rf "$TBLSPC_ROOT1"
rm -rf "$RESTORE_ROOT1"
#!/bin/sh
set -eu

PGDATA="$HOME/ejl64"
PGPORT=9437

pg_ctl -D "$PGDATA" status
psql -p "$PGPORT" -d postgres -c "SELECT pg_is_in_recovery();"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) FROM client;"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) FROM pay;"
psql -p "$PGPORT" -d postgres -c "\db+"
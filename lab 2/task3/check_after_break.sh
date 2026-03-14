#!/bin/sh

PGDATA="$HOME/ejl64"
PGPORT=9437

echo "до перезапуска"
pg_ctl -D "$PGDATA" status || true
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) FROM client;"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) FROM pay;"

echo
echo "перезапуск"
pg_ctl -D "$PGDATA" restart -m fast || true

echo
echo "логи"
tail -n 30 "$PGDATA/server.log" || true
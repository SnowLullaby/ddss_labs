#!/bin/sh

PGPORT=9437

echo "+++ postgres"
psql -p "$PGPORT" -d postgres -v ON_ERROR_STOP=1 -f sql/fill_postgres.sql
echo

echo "+++ longpinksoup"
psql -p "$PGPORT" -d longpinksoup -v ON_ERROR_STOP=1 -f sql/fill_long.sql
echo
#!/bin/sh

PGPORT=9437

psql -p "$PGPORT" -d postgres <<'SQL'
CREATE ROLE soup LOGIN;

GRANT CONNECT, TEMP ON DATABASE postgres TO soup;
GRANT CONNECT, TEMP ON DATABASE longpinksoup TO soup;

GRANT USAGE, CREATE ON SCHEMA public TO soup;
GRANT CREATE ON TABLESPACE uvx79 TO soup;
GRANT CREATE ON TABLESPACE hqj18 TO soup;
SQL

psql -p "$PGPORT" -d longpinksoup -c "GRANT USAGE, CREATE ON SCHEMA public TO soup;"
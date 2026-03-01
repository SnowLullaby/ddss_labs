#!/bin/sh

PGDATA="$HOME/ejl64"
pg_ctl -D "$PGDATA" -l "$PGDATA/server.log" start
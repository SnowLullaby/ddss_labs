#!/bin/sh

PGPORT=9437

mkdir -p "$HOME/uvx79"
mkdir -p "$HOME/hqj18"

psql -p "$PGPORT" -d postgres -c "CREATE TABLESPACE uvx79 LOCATION '$HOME/uvx79';"
psql -p "$PGPORT" -d postgres -c "CREATE TABLESPACE hqj18 LOCATION '$HOME/hqj18';"
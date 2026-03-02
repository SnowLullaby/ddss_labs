#!/bin/sh

PGPORT=9437

psql -p "$PGPORT" -d postgres -c "CREATE DATABASE longpinksoup TEMPLATE template1;"
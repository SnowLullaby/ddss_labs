#!/bin/sh

PGDATA="$HOME/ejl64"
PGLOCALE="ru_RU.KOI8-R"
PGENCODE="KOI8-R"
PGUSERNAME="$USER"

initdb -D "$PGDATA" \
  --encoding="$PGENCODE" \
  --locale="$PGLOCALE" \
  --lc-collate="$PGLOCALE" \
  --lc-ctype="$PGLOCALE" \
  --lc-messages="$PGLOCALE" \
  --lc-monetary="$PGLOCALE" \
  --lc-numeric="$PGLOCALE" \
  --lc-time="$PGLOCALE" \
  --username="$PGUSERNAME"
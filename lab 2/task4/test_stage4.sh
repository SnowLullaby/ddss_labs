#!/bin/sh
set -eu

PGPORT=9437

psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS client_after_restore FROM public.client;"
psql -p "$PGPORT" -d longpinksoup -c "SELECT count(*) AS pay_after_restore FROM public.pay;"
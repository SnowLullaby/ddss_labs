#!/bin/sh
set -eu

PGPORT=9437

psql -p "$PGPORT" -d longpinksoup <<'SQL'
DELETE FROM public.pay
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid, row_number() OVER (ORDER BY ctid) AS rn
        FROM public.pay
    ) s
    WHERE rn % 2 = 0
);

DELETE FROM public.client
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT ctid, row_number() OVER (ORDER BY ctid) AS rn
        FROM public.client
    ) s
    WHERE rn % 2 = 0
);

SELECT count(*) AS client_after_delete FROM public.client;
SELECT count(*) AS pay_after_delete FROM public.pay;
SQL
#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres

psql -P pager=off -t -A -F '|' -h pgpool -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;" \
| awk -F'|' '$7=="primary"{print $2; exit}'

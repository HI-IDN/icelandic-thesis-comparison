#!/usr/bin/env bash

set -euo pipefail

DB_PATH="${1:-data/processed/thesis.db}"
OUT_FILE="${2:-scripts/create_thesis_db.sql}"

duckdb "$DB_PATH" <<'SQL' > "$OUT_FILE"
select sql
from duckdb_sequences()

union all

select sql
from duckdb_tables()

union all

select sql
from duckdb_indexes()

union all

select sql
from duckdb_views()

order by sql;
SQL

echo "Schema written to $OUT_FILE"
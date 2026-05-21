#!/usr/bin/env bash
set -euo pipefail

DB_PATH="${1:-data/processed/thesis.db}"
IDS="${2:-4445,25337}"

# Ensure metadata tables exist (and are up to date).
duckdb "$DB_PATH" < scripts/create_thesis_db.sql

# Clear related tables before reloading metadata.
duckdb "$DB_PATH" "delete from thesis_people;"
duckdb "$DB_PATH" "delete from people;"
duckdb "$DB_PATH" "delete from thesis_metadata;"

# Reload metadata for the requested ids.
python scripts/metadata_load.py --db "$DB_PATH" --ids "$IDS"

# Print test metadata to the console.
duckdb "$DB_PATH" "select * from thesis_metadata where thesis_id in (${IDS});"

duckdb "$DB_PATH" "select tp.thesis_id, p.name, p.year_born, p.year_died, tp.role, p.id from thesis_people tp join people p on p.id = tp.person_id where tp.thesis_id in (${IDS}) order by tp.thesis_id, tp.role, p.name;"

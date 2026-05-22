# Icelandic Thesis Metadata Loader

This repository collects Icelandic BSc and master's thesis records from Skemman into DuckDB.

The current workflow has two steps:

1. Run Skemman `simple-search` for the HI and HR handles, year by year for 2010 through 2026.
2. Run the metadata loader. It fetches each Skemman item page unless the cached HTML file already exists, then parses the relevant metadata into normalized database tables.

## Install

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

PowerShell activation:

```powershell
.venv\Scripts\activate
```

## Initialize Database

```bash
duckdb data/processed/thesis.db < scripts/create_thesis_db.sql
```

## Step 1: Capture Listings

Run simple search for each handle and year:

```bash
for handle in 1946/2064 1946/6870; do
  for year in $(seq 2010 2026); do
    skemman simple-search --location "$handle" --year "$year" --output data/processed/thesis.db
  done
done
```

PowerShell:

```powershell
$handles = @("1946/2064", "1946/6870")
foreach ($handle in $handles) {
  foreach ($year in 2010..2026) {
    skemman simple-search --location $handle --year $year --output data/processed/thesis.db
  }
}
```

## Step 2: Load Metadata

Load metadata for all thesis IDs that are missing metadata:

```bash
skemman metadata-load --db data/processed/thesis.db
```

For a selected set of IDs:

```bash
skemman metadata-load --db data/processed/thesis.db --ids 4445,25337
```

Raw item HTML is cached under `data/raw/items/`. If `data/raw/items/<thesis_id>.html` exists, the loader reuses it instead of fetching the page again.

## Documentation

The database mapping is documented in [docs/skemman_database_mapping.md](docs/skemman_database_mapping.md).

Useful SQL checks are in `scripts/useful_queries.sql` and `scripts/test_metadata.sql`.

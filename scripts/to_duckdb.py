from __future__ import annotations

import argparse
from pathlib import Path

import duckdb
import pandas as pd


def _table_name(name: str) -> str:
    safe = "".join(ch if ch.isalnum() or ch == "_" else "_" for ch in name)
    if not safe:
        safe = "data"
    if safe[0].isdigit():
        safe = f"t_{safe}"
    return safe


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Store a CSV/Parquet file in a DuckDB database.")
    parser.add_argument("--input", required=True, help="Input .parquet or .csv file")
    parser.add_argument("--output", required=True, help="Output .duckdb database file")
    parser.add_argument("--table", help="Table name (defaults to output file stem)")
    parser.add_argument("--overwrite", action="store_true", help="Replace table if it exists")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    if input_path.suffix.lower() == ".csv":
        df = pd.read_csv(input_path)
    else:
        df = pd.read_parquet(input_path)

    table = _table_name(args.table or output_path.stem)

    if output_path.exists() and not args.overwrite:
        print(f"{output_path} already exists. Use --overwrite to replace {table}.")
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with duckdb.connect(str(output_path)) as con:
        con.register("df", df)
        con.execute(f"create or replace table {table} as select * from df")

    print(f"Wrote {len(df)} rows to {output_path} ({table}).")


if __name__ == "__main__":
    main()

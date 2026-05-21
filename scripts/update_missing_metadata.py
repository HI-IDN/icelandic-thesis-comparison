from __future__ import annotations

import argparse
import subprocess
import sys
from typing import Iterable

import duckdb


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch metadata only for thesis ids missing thesis_metadata rows."
    )
    parser.add_argument(
        "--db",
        default="data/processed/thesis.db",
        help="DuckDB database path",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=2.0,
        help="Delay between requests (seconds)",
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=50,
        help="Number of ids per metadata_load call",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Optional cap on number of ids to process",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print ids to update without fetching",
    )
    return parser.parse_args()


def chunked(values: list[int], size: int) -> Iterable[list[int]]:
    for i in range(0, len(values), size):
        yield values[i: i + size]


def main() -> None:
    args = parse_args()

    print(f"Scanning for missing thesis_metadata rows in {args.db}...")
    with duckdb.connect(args.db, read_only=True) as con:
        rows = con.execute(
            """
            select t.id
            from thesis t
                     left join thesis_metadata m on m.thesis_id = t.id
            where m.thesis_id is null
            order by t.id
            """
        ).fetchall()

    ids = [int(row[0]) for row in rows if row and row[0] is not None]
    if args.limit is not None:
        ids = ids[: args.limit]

    if not ids:
        print("No missing thesis_metadata rows found.")
        return

    total = len(ids)
    print(f"Found {total} thesis ids missing metadata.")
    if args.dry_run:
        print(",".join(str(value) for value in ids))
        return

    processed = 0
    batches = list(chunked(ids, max(args.batch_size, 1)))
    for index, batch in enumerate(batches, start=1):
        id_list = ",".join(str(value) for value in batch)
        print(f"Batch {index}/{len(batches)}: {id_list}")
        subprocess.run(
            [
                sys.executable,
                "scripts/metadata_load.py",
                "--db",
                args.db,
                "--ids",
                id_list,
                "--delay",
                str(args.delay),
            ],
            check=True,
        )
        processed += len(batch)
        print(f"Progress: {processed}/{total} ({processed * 100 // total}%)")

    print("Metadata update complete.")


if __name__ == "__main__":
    main()

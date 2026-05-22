from __future__ import annotations

import argparse
import random
import subprocess
import sys
from typing import Iterable

import duckdb

DEFAULT_IDS = [
    2734,
    2778,
    2916,
    3050,
    3051,
    3373,
    4025,
    4176,
    4426,
    4460,
    5274,
    5335,
    5583,
]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Refresh metadata for a fixed list of thesis ids plus a random sample "
            "from the thesis table."
        )
    )
    parser.add_argument(
        "--db",
        default="data/processed/thesis.db",
        help="DuckDB database path",
    )
    parser.add_argument(
        "--ids",
        help="Comma-separated thesis ids to refresh (defaults to built-in list)",
    )
    parser.add_argument(
        "--sample-size",
        type=int,
        default=10,
        help="Number of additional random thesis ids to include",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=20260522,
        help="Random seed for reproducible sampling",
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
        "--dry-run",
        action="store_true",
        help="Print ids to update without fetching",
    )
    return parser.parse_args()


def parse_ids(raw: str | None) -> list[int]:
    if not raw:
        return DEFAULT_IDS.copy()
    out: list[int] = []
    for part in raw.split(","):
        value = part.strip()
        if value:
            out.append(int(value))
    return out


def chunked(values: list[int], size: int) -> Iterable[list[int]]:
    for i in range(0, len(values), size):
        yield values[i: i + size]


def main() -> None:
    args = parse_args()
    base_ids = parse_ids(args.ids)

    with duckdb.connect(args.db, read_only=True) as con:
        rows = con.execute("select id from thesis order by id").fetchall()

    all_ids = [int(row[0]) for row in rows if row and row[0] is not None]
    excluded = set(base_ids)
    remaining = [value for value in all_ids if value not in excluded]

    rng = random.Random(args.seed)
    sample_size = max(args.sample_size, 0)
    if sample_size >= len(remaining):
        sampled = remaining
    else:
        sampled = rng.sample(remaining, sample_size)

    combined = base_ids + sampled

    print("Refresh ids:")
    print(",".join(str(value) for value in combined))

    if args.dry_run:
        return

    batches = list(chunked(combined, max(args.batch_size, 1)))
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

    print("Selected metadata refresh complete.")


if __name__ == "__main__":
    main()

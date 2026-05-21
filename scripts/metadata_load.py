from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Iterable

import duckdb
from bs4 import BeautifulSoup

from skemman_scraper.utils import PoliteSession


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch Skemman item pages, parse metadata, and insert into DuckDB."
    )
    parser.add_argument(
        "--db",
        default="data/processed/thesis.db",
        help="DuckDB database path",
    )
    parser.add_argument(
        "--ids",
        help="Comma-separated thesis ids (e.g., 4445,25337)",
    )
    parser.add_argument(
        "--urls",
        help="Comma-separated item URLs (overrides --ids)",
    )
    parser.add_argument(
        "--out-html",
        default="data/raw/items",
        help="Directory to save raw HTML pages",
    )
    parser.add_argument(
        "--user-agent",
        default="skemman-metadata-loader",
        help="User-Agent header for requests",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=2.0,
        help="Delay between requests (seconds)",
    )
    return parser.parse_args()


def normalise_text(value: str | None) -> str | None:
    if value is None:
        return None
    text = re.sub(r"\s+", " ", value).strip()
    return text or None


def metadata_from_html(html: str) -> dict[str, list[str]]:
    soup = BeautifulSoup(html, "html.parser")
    metadata: dict[str, list[str]] = {}

    for row in soup.find_all("tr"):
        cells = row.find_all(["th", "td"])
        if len(cells) >= 2:
            key = normalise_text(cells[0].get_text(" "))
            val = normalise_text(cells[1].get_text(" "))
            if key and val:
                metadata.setdefault(key.rstrip(":"), []).append(val)

    for dt in soup.find_all("dt"):
        key = normalise_text(dt.get_text(" "))
        dd = dt.find_next_sibling("dd")
        val = normalise_text(dd.get_text(" ")) if dd else None
        if key and val:
            metadata.setdefault(key.rstrip(":"), []).append(val)

    for meta in soup.find_all("meta"):
        key = meta.get("name") or meta.get("property")
        val = meta.get("content")
        if key and val:
            metadata.setdefault(key, []).append(normalise_text(val) or val)

    return metadata


def get_first(metadata: dict[str, list[str]], *keys: str) -> str | None:
    lowered = {k.lower(): v for k, v in metadata.items()}
    for key in keys:
        values = lowered.get(key.lower())
        if values:
            return values[0]
    return None


def get_all(metadata: dict[str, list[str]], *keys: str) -> list[str]:
    lowered = {k.lower(): v for k, v in metadata.items()}
    out: list[str] = []
    for key in keys:
        out.extend(lowered.get(key.lower(), []))
    return [v for v in out if v]


def split_keywords(values: list[str]) -> list[str]:
    out: list[str] = []
    for value in values:
        parts = [p.strip() for p in re.split(r"[;,]", value)]
        out.extend([p for p in parts if p])
    return out


def is_person_candidate(text: str) -> bool:
    return bool(re.search(r"\d{4}-(\d{4})?$", text) or re.search(r"\w+,\s*\w+", text))


def pick_degree(types: list[str]) -> str | None:
    for value in types:
        degree = normalise_degree(value)
        if degree:
            return degree
    return None


def normalise_degree(value: str | None) -> str | None:
    if not value:
        return None
    low = value.lower()
    if "doktor" in low or "phd" in low:
        return "phd"
    if "meist" in low or "master" in low or "msc" in low:
        return "master"
    if "bachelor" in low or "b.sc" in low or "bsc" in low:
        return "bachelor"
    return None


def parse_person_name(text: str) -> tuple[str, int | None, int | None]:
    cleaned = normalise_text(text) or ""
    match = re.match(r"^(.*?)(?:\s+(\d{4})-(\d{4})?)?$", cleaned)
    if not match:
        return cleaned, None, None
    name = match.group(1).strip()
    year_born = int(match.group(2)) if match.group(2) else None
    year_died = int(match.group(3)) if match.group(3) else None
    return name, year_born, year_died


def ensure_person(
        con: duckdb.DuckDBPyConnection,
        name: str,
        year_born: int | None,
        year_died: int | None,
) -> int:
    row = con.execute(
        """
        select id
        from people
        where name = ?
          and coalesce(year_born, -1) = coalesce(?, -1)
          and coalesce(year_died, -1) = coalesce(?, -1)
        """,
        [name, year_born, year_died],
    ).fetchone()
    if row:
        return int(row[0])
    inserted = con.execute(
        "insert into people (name, year_born, year_died) values (?, ?, ?) returning id",
        [name, year_born, year_died],
    ).fetchone()
    return int(inserted[0])


def insert_people_links(
        con: duckdb.DuckDBPyConnection,
        thesis_id: int,
        people: Iterable[tuple[str, int | None, int | None]],
        role: str,
) -> None:
    for name, year_born, year_died in people:
        if not name:
            continue
        person_id = ensure_person(con, name, year_born, year_died)
        con.execute(
            """
            insert into thesis_people (thesis_id, person_id, role)
            select ?,
                   ?,
                   ? where not exists (
                select 1 from thesis_people
                where thesis_id = ? and person_id = ? and role = ?
            )
            """,
            [thesis_id, person_id, role, thesis_id, person_id, role],
        )


def resolve_urls(ids: str | None, urls: str | None) -> list[str]:
    if urls:
        return [u.strip() for u in urls.split(",") if u.strip()]
    if ids:
        out: list[str] = []
        for part in ids.split(","):
            value = part.strip()
            if value:
                out.append(f"https://skemman.is/handle/1946/{value}")
        return out
    return []


def extract_id_from_url(url: str) -> int | None:
    match = re.search(r"/handle/\d+/(\d+)$", url)
    return int(match.group(1)) if match else None


def main() -> None:
    args = parse_args()
    urls = resolve_urls(args.ids, args.urls)
    if not urls:
        raise SystemExit("Provide --ids or --urls.")

    out_dir = Path(args.out_html)
    out_dir.mkdir(parents=True, exist_ok=True)

    session = PoliteSession(
        user_agent=args.user_agent,
        delay_seconds=args.delay,
        timeout_seconds=30,
        cache_dir=None,
    )

    with duckdb.connect(args.db) as con:
        for url in urls:
            html = session.get_text(url, use_cache=False)
            thesis_id = extract_id_from_url(url)
            if thesis_id is None:
                continue

            (out_dir / f"{thesis_id}.html").write_text(html, encoding="utf-8")
            metadata = metadata_from_html(html)

            title_en = get_first(metadata, "DCTERMS.title", "citation_title", "Title", "dc.title")
            title_is = get_first(metadata, "DCTERMS.alternative", "Titill")

            abstract_is = get_first(metadata, "DCTERMS.abstract", "Útdráttur")
            abstract_en = get_first(metadata, "Abstract", "dc.description.abstract")

            types = get_all(metadata, "DCTERMS.type", "Type", "dc.type")
            degree_raw = get_first(metadata, "Námsstig", "Degree", "dc.description.degree")
            thesis_type = "; ".join(types) if types else None

            sponsor = get_first(metadata, "Styrktaraðili", "Sponsor")
            related_url = get_first(metadata, "Tengd vefslóð", "Related URL", "DCTERMS.relation")
            keywords = split_keywords(
                get_all(metadata, "DCTERMS.subject", "citation_keywords", "Efnisorð", "dc.subject")
            )

            descriptions = get_all(metadata, "DCTERMS.description")
            advisor_fallback = [d for d in descriptions if is_person_candidate(d)]
            sponsor_fallback = [d for d in descriptions if d not in advisor_fallback]
            if not sponsor and sponsor_fallback:
                sponsor = "; ".join(sponsor_fallback)

            con.execute("delete from thesis_metadata where thesis_id = ?", [thesis_id])
            con.execute(
                """
                insert into thesis_metadata (thesis_id,
                                             title_is,
                                             title_en,
                                             abstract_is,
                                             abstract_en,
                                             degree_level,
                                             thesis_type,
                                             sponsor,
                                             related_url,
                                             raw_keywords)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                [
                    thesis_id,
                    title_is,
                    title_en,
                    abstract_is,
                    abstract_en,
                    normalise_degree(degree_raw) or pick_degree(types),
                    thesis_type,
                    sponsor,
                    related_url,
                    "; ".join(keywords) if keywords else None,
                ],
            )

            authors = get_all(
                metadata,
                "DCTERMS.creator",
                "citation_author",
                "Höfundur",
                "Höfundar",
                "Author",
                "dc.contributor.author",
            )
            advisors = get_all(
                metadata,
                "Leiðbeinandi",
                "Leiðbeinendur",
                "Advisor",
                "dc.contributor.advisor",
            )
            if not advisors and advisor_fallback:
                advisors = advisor_fallback

            author_people = [parse_person_name(a) for a in authors]
            advisor_people = [parse_person_name(a) for a in advisors]

            insert_people_links(con, thesis_id, author_people, "author")
            insert_people_links(con, thesis_id, advisor_people, "advisor")


if __name__ == "__main__":
    main()

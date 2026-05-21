# Icelandic Thesis Scraper and Comparison (Skemman + Opin vísindi)

Starter repository for collecting and analyzing thesis metadata from [Skemman](https://skemman.is/),
with an initial focus on comparing Háskóli Íslands (HÍ) and Háskólinn í Reykjavík (HR) across B.S.,
M.S., and PhD levels.

The project is designed for a research workflow:

1. harvest public Skemman collection/item metadata;
2. extract abstracts and public PDF text where available;
3. classify thesis topics and external industry/institution involvement;
4. export reproducible analysis tables for R, Python, Quarto, or LaTeX.

## Initial target collections

The seed configuration includes:

| Institution                                                   | Handle      | Subcollections (examples)                                                                            |
|---------------------------------------------------------------|-------------|------------------------------------------------------------------------------------------------------|
| Háskóli Íslands (HÍ) – Verkfræði- og náttúruvísindasvið       | `1946/2064` | B.S. verkefni; Meistaraprófsritgerðir; Doktorsritgerðir                                              |
| Háskólinn í Reykjavík (HR) – Tæknisvið / School of Technology | `1946/6870` | BSc Tæknifræðideild; BSc Tölvunarfræðideild; BSc Verkfræðideild; MSc Tölvunarfræðideild; PhD (-2016) |

## Install

```bash
python -m venv .venv
source .venv/bin/activate  # Windows MSYS/Git Bash
# or: .venv\Scripts\activate  # PowerShell
pip install -r requirements.txt
```

## Run

Create the database schema (table + view):

```bash
duckdb data/processed/thesis.db < scripts/create_thesis_db.sql
```

Single-page listing capture (25 rows per page):

```bash
skemman simple-search --location 1946/6870 --year 2016 --no-paginate --output data/processed/thesis.db
```

Year-by-year capture (2010–2026) for both handles:

```bash
for i in {2010..2026}; do
  echo $i
  skemman simple-search --location 1946/2064 --year $i --output data/processed/thesis.db
  skemman simple-search --location 1946/6870 --year $i --output data/processed/thesis.db
 done
```

Notes:

- The scraper builds the URL for you; the exact URL is printed and also stored in the `source_url`
  column.
- Pagination is on by default; use `--no-paginate` for a single page.
- Use `--year` to filter; no additional limiting is applied.
- You can pass locations as `1946/24751` or `1946 24751`.

Future work (not implemented yet):

- Harvest item pages for richer metadata.
- Extract PDF text for public PDFs.
- Classify topics and external involvement.
- Export analysis tables.

Full URL capture (use the exact query you want):

```bash
skemman simple-search --url "https://skemman.is/simple-search?location=1946%2F6870&query=&filtername=dateIssued&filtertype=equals&filterquery=2016&doSearch=Leita&rpp=25&sort_by=score&order=desc" --output data/processed/thesis.db
```

Háskóli Íslands example (year filter in the URL):

```bash
skemman simple-search --url "https://skemman.is/simple-search?location=1946%2F2064&query=&filter_field_1=dateIssued&filter_type_1=equals&filter_value_1=2016&filtername=author&filtertype=equals&filterquery=&doSearch=Leita&rpp=25&sort_by=score&order=desc" --output data/processed/thesis.db
```

## Configuration

Scrape controls live in `config/collections.yaml` (and the minimal `config/collections.small.yaml`).

- `institutions[].enabled`: toggle institutions on/off
- `institutions[].seed_handles`: starting collection handles
- `year_min` / `year_max`: optional year filter based on the item date
- `request_delay_seconds`, `user_agent`, `cache_html`: polite crawling

## Data notes

Outputs are written as Parquet in `data/processed/`. DuckDB can query Parquet directly without
conversion (optional).

## Important research and ethics notes

Skemman contains copyrighted thesis material. This project is intended to extract structured
metadata, short evidence snippets, and research classifications. Do not redistribute downloaded PDFs
or large extracted text fields. Store raw PDFs locally only when necessary and permitted by the
repository's access conditions.

Note: PhD theses after 2016 are hosted in [Opin vísindi](https://opinvisindi.is/). Skemman scraping
is the current focus; Opin vísindi support is a planned TODO.

Use polite crawling:

- add a descriptive user-agent;
- sleep between requests;
- cache downloaded pages;
- avoid repeated large recrawls;
- stop immediately if robots.txt or site terms prohibit the intended access pattern.

## Proposed coding scheme: external involvement

The default classifier uses a graded variable rather than a binary flag.

| Code | Meaning                                          |
|-----:|--------------------------------------------------|
|    0 | No external actor visible                        |
|    1 | External actor mentioned only as context         |
|    2 | External data/source used                        |
|    3 | Thesis done with or for an external organisation |
|    4 | Employment/industrial project explicitly stated  |

The classifier should keep an evidence sentence and confidence score for auditability.

## Repository layout

```text
config/
  collections.yaml          # seed handles and crawl settings
  collections.small.yaml    # minimal sanity-check config
scripts/
  to_duckdb.py              # convert CSV/Parquet to DuckDB
src/skemman_scraper/
  cli.py                    # command line interface
  config.py                 # config loading
  harvest.py                # collection/item crawling
  parse.py                  # HTML parsing helpers
  pdf_text.py               # public PDF text extraction
  classify.py               # rule-based classification scaffold
  simple_search.py          # simple-search listing scraper
  storage.py                # parquet/csv helpers
  models.py                 # dataclasses
  utils.py                  # HTTP/cache helpers
data/
  raw/                      # cached pages/PDFs; ignored by git
  processed/                # parquet outputs; ignored by git
outputs/                    # CSV/tables/figures; ignored by git
```

## Suggested analysis questions

- How do thesis topics differ between BS, MS, and PhD levels?
- How do HÍ and HR differ in topic mix over time?
- How often do theses show evidence of industry or public-sector collaboration?
- Are external collaborations concentrated in particular departments, levels, or topic areas?
- Do topic trends change before/after major institutional or curriculum changes?

-- Useful DuckDB queries for thesis.db

-- Count rows by submitted year (date_accepted stored as dd.mm.yyyy).
select extract(year from try_strptime(date_accepted, '%d.%m.%Y')) as year,
  count(*) as n
from thesis
group by year
order by year;


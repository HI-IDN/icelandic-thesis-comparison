-- Useful DuckDB queries for thesis.db

-- Simple comparison: counts per year.
select extract(year from date_accepted) as year,
  count(*) as n
from thesis
group by year
order by year;

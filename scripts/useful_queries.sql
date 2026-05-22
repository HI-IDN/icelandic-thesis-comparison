-- Useful DuckDB queries for thesis.db

-- Simple comparison: counts per year.
select extract(year from date_accepted) as year,
  count(*) as n
from thesis
group by year
order by year;

-- Metadata coverage: how many theses have metadata rows.
select count(*)                      as total_thesis,
       count(m.thesis_id)            as with_metadata,
       count(*) - count(m.thesis_id) as missing_metadata
from thesis t
         left join thesis_metadata m on m.thesis_id = t.id;

-- Missing metadata rows (ids).
select t.id
from thesis t
         left join thesis_metadata m on m.thesis_id = t.id
where m.thesis_id is null
order by t.id;

-- Metadata completeness checks for key fields.
select thesis_id,
       title_is is not null    as has_title_is,
       title_en is not null    as has_title_en,
       abstract_is is not null as has_abstract_is,
       abstract_en is not null as has_abstract_en,
       sponsor is not null     as has_sponsor,
       pdf_url is not null     as has_pdf_url
from thesis_metadata
order by thesis_id;

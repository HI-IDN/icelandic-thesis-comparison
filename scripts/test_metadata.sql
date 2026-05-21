-- People linked to test theses (readable names).
select tp.thesis_id,
       p.name,
       p.year_born,
       p.year_died,
       tp.role
from thesis_people tp
         join people p on p.id = tp.person_id
where tp.thesis_id in (4445, 25337)
order by tp.thesis_id, tp.role, p.name;

-- Meta data to test thesis
select *
from thesis_metadata
where thesis_id in (4445, 25337);
-- Create the thesis table with the expected schema and a view for item_url.

create table if not exists thesis
(
    id
    integer,
    date_accepted
    date,
    title
    varchar,
    authors
    varchar
);

create
or replace view v_thesis as
select id,
       date_accepted,
       title,
       authors,
       'https://skemman.is/handle/1946/' || id as item_url
from thesis;


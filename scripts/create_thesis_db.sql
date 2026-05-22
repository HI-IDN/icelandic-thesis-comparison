-- Create thesis, view, and metadata tables without changing existing data.

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

create unique index if not exists thesis_id_pk on thesis(id);

create
or replace view v_thesis as
select id,
       date_accepted,
       title,
       authors,
       'https://skemman.is/handle/1946/' || id as item_url
from thesis;

-- Create thesis_metadata and people tables without changing existing thesis or v_thesis.

create table if not exists thesis_metadata
(
    thesis_id
    integer,
    title_is
    varchar,
    title_en
    varchar,
    abstract_is
    varchar,
    abstract_en
    varchar,
    degree_level
    varchar,
    thesis_type
    varchar,
    sponsor
    varchar,
    note
    varchar,
    related_url
    varchar,
    raw_keywords
    varchar,
    pdf_url
    varchar,
    institution
    varchar,
    school
    varchar
);

create sequence if not exists people_id_seq;

create table if not exists people
(
    id
    bigint
    default
    nextval
(
    'people_id_seq'
),
    name
    varchar,
    year_born
    integer,
    year_died
    integer
);

create unique index if not exists people_id_pk on people(id);
create unique index if not exists people_name_year_pk on people(name, year_born);

create table if not exists thesis_people
(
    thesis_id
    integer,
    person_id
    bigint,
    role
    varchar
);

create unique index if not exists thesis_people_pk on thesis_people(thesis_id, person_id, role);

create sequence if not exists keyword_id_seq start 1;
create sequence if not exists people_id_seq start 1;

create table if not exists thesis
(
    id            integer,
    date_accepted date,
    title         varchar,
    authors       varchar
);

create table if not exists thesis_metadata
(
    thesis_id         integer,
    title_is          varchar,
    title_en          varchar,
    abstract_is       varchar,
    abstract_en       varchar,
    degree_level      varchar,
    thesis_type       varchar,
    sponsor           varchar,
    note              varchar,
    related_url       varchar,
    raw_keywords      varchar,
    pdf_url           varchar,
    institution       varchar,
    school            varchar,
    university        varchar,
    faculty           varchar,
    study_category    varchar,
    thesis_type_label varchar
);

create table if not exists people
(
    id        bigint default nextval('people_id_seq'),
    name      varchar,
    year_born integer,
    year_died integer
);

create table if not exists thesis_people
(
    thesis_id  integer,
    person_id  bigint,
    role       varchar,
    sort_order integer
);

create table if not exists keywords
(
    id           bigint default nextval('keyword_id_seq'),
    keyword      varchar,
    keyword_norm varchar
);

create table if not exists thesis_keywords
(
    thesis_id  integer,
    keyword_id bigint,
    sort_order integer
);

create unique index if not exists thesis_id_pk on thesis (id);
create unique index if not exists people_id_pk on people (id);
create unique index if not exists people_name_year_uq on people (name, year_born);
create unique index if not exists keywords_norm_uq on keywords (keyword_norm);
create unique index if not exists thesis_people_uq on thesis_people (thesis_id, person_id, role);
create unique index if not exists thesis_keywords_uq on thesis_keywords (thesis_id, keyword_id);

create or replace view v_thesis as
select
    id,
    date_accepted,
    title,
    authors,
    'https://skemman.is/handle/1946/' || id as item_url
from thesis;

create or replace view v_thesis_metadata as
with author_lists as (
    select
        tp.thesis_id,
        array_agg(p.name order by tp.sort_order) as authors
    from thesis_people tp
    join people p on p.id = tp.person_id
    where tp.role = 'author'
    group by tp.thesis_id
),
advisor_lists as (
    select
        tp.thesis_id,
        array_agg(p.name order by tp.sort_order) as advisors
    from thesis_people tp
    join people p on p.id = tp.person_id
    where tp.role = 'advisor'
    group by tp.thesis_id
),
keyword_lists as (
    select
        tk.thesis_id,
        array_agg(k.keyword order by tk.sort_order) as keywords
    from thesis_keywords tk
    join keywords k on k.id = tk.keyword_id
    group by tk.thesis_id
)
select
    m.*,
    a.authors,
    ad.advisors,
    k.keywords
from thesis_metadata m
left join author_lists a on a.thesis_id = m.thesis_id
left join advisor_lists ad on ad.thesis_id = m.thesis_id
left join keyword_lists k on k.thesis_id = m.thesis_id;

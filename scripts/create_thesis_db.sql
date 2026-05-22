CREATE SEQUENCE keyword_id_seq INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 1 NO CYCLE;
CREATE SEQUENCE people_id_seq INCREMENT BY 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 9225 NO CYCLE;
CREATE TABLE keywords
(
    id           BIGINT DEFAULT (nextval('keyword_id_seq')),
    keyword      VARCHAR,
    keyword_norm VARCHAR
);
CREATE TABLE people
(
    id        BIGINT DEFAULT (nextval('people_id_seq')),
    "name"    VARCHAR,
    year_born INTEGER,
    year_died INTEGER
);
CREATE TABLE thesis
(
    id            INTEGER,
    date_accepted DATE,
    title         VARCHAR,
    authors       VARCHAR
);
CREATE TABLE thesis_keywords
(
    thesis_id  INTEGER,
    keyword_id BIGINT,
    sort_order INTEGER
);
CREATE TABLE thesis_metadata
(
    thesis_id         INTEGER,
    title_is          VARCHAR,
    title_en          VARCHAR,
    abstract_is       VARCHAR,
    abstract_en       VARCHAR,
    degree_level      VARCHAR,
    thesis_type       VARCHAR,
    sponsor           VARCHAR,
    note              VARCHAR,
    related_url       VARCHAR,
    raw_keywords      VARCHAR,
    pdf_url           VARCHAR,
    institution       VARCHAR,
    school            VARCHAR,
    university        VARCHAR,
    faculty           VARCHAR,
    study_category    VARCHAR,
    thesis_type_label VARCHAR
);
CREATE TABLE thesis_people
(
    thesis_id  INTEGER,
    person_id  BIGINT,
    "role"     VARCHAR,
    sort_order INTEGER
);
CREATE
TEMP VIEW duckdb_columns AS
SELECT *
FROM duckdb_columns()
WHERE (NOT internal);
CREATE
TEMP VIEW duckdb_constraints AS
SELECT *
FROM duckdb_constraints();
CREATE
TEMP VIEW duckdb_databases AS
SELECT *
FROM duckdb_databases()
WHERE (NOT internal);
CREATE
TEMP VIEW duckdb_indexes AS
SELECT *
FROM duckdb_indexes();
CREATE
TEMP VIEW duckdb_logs AS
SELECT *
FROM duckdb_logs((denormalized_table = CAST('t' AS BOOLEAN)));
CREATE
TEMP VIEW duckdb_schemas AS
SELECT *
FROM duckdb_schemas()
WHERE (NOT internal);
CREATE
TEMP VIEW duckdb_tables AS
SELECT *
FROM duckdb_tables()
WHERE (NOT internal);
CREATE
TEMP VIEW duckdb_types AS
SELECT *
FROM duckdb_types();
CREATE
TEMP VIEW duckdb_views AS
SELECT *
FROM duckdb_views()
WHERE (NOT internal);
CREATE
TEMP VIEW information_schema."columns" AS
SELECT database_name                                      AS table_catalog,
       schema_name                                        AS table_schema,
       table_name,
       column_name,
       column_index                                       AS ordinal_position,
       column_default,
       CASE WHEN (is_nullable) THEN ('YES') ELSE 'NO' END AS is_nullable,
       data_type,
       character_maximum_length,
       CAST(NULL AS INTEGER)                              AS character_octet_length,
       numeric_precision,
       numeric_precision_radix,
       numeric_scale,
       CAST(NULL AS INTEGER)                              AS datetime_precision,
       CAST(NULL AS VARCHAR)                              AS interval_type,
       CAST(NULL AS INTEGER)                              AS interval_precision,
       CAST(NULL AS VARCHAR)                              AS character_set_catalog,
       CAST(NULL AS VARCHAR)                              AS character_set_schema,
       CAST(NULL AS VARCHAR)                              AS character_set_name,
       CAST(NULL AS VARCHAR)                              AS collation_catalog,
       CAST(NULL AS VARCHAR)                              AS collation_schema,
       CAST(NULL AS VARCHAR)                              AS collation_name,
       CAST(NULL AS VARCHAR)                              AS domain_catalog,
       CAST(NULL AS VARCHAR)                              AS domain_schema,
       CAST(NULL AS VARCHAR)                              AS domain_name,
       CAST(NULL AS VARCHAR)                              AS udt_catalog,
       CAST(NULL AS VARCHAR)                              AS udt_schema,
       CAST(NULL AS VARCHAR)                              AS udt_name,
       CAST(NULL AS VARCHAR)                              AS scope_catalog,
       CAST(NULL AS VARCHAR)                              AS scope_schema,
       CAST(NULL AS VARCHAR)                              AS scope_name,
       CAST(NULL AS BIGINT)                               AS maximum_cardinality,
       CAST(NULL AS VARCHAR)                              AS dtd_identifier,
       CAST(NULL AS BOOLEAN)                              AS is_self_referencing,
       CAST(NULL AS BOOLEAN)                              AS is_identity,
       CAST(NULL AS VARCHAR)                              AS identity_generation,
       CAST(NULL AS VARCHAR)                              AS identity_start,
       CAST(NULL AS VARCHAR)                              AS identity_increment,
       CAST(NULL AS VARCHAR)                              AS identity_maximum,
       CAST(NULL AS VARCHAR)                              AS identity_minimum,
       CAST(NULL AS BOOLEAN)                              AS identity_cycle,
       CAST(NULL AS VARCHAR)                              AS is_generated,
       CAST(NULL AS VARCHAR)                              AS generation_expression,
       CAST(NULL AS BOOLEAN)                              AS is_updatable,
       "comment"                                          AS COLUMN_COMMENT
FROM duckdb_columns;
CREATE
TEMP VIEW information_schema."tables" AS (SELECT database_name AS table_catalog, schema_name AS table_schema, table_name, CASE  WHEN ("temporary") THEN ('LOCAL TEMPORARY') ELSE 'BASE TABLE' END AS table_type, CAST(NULL AS VARCHAR) AS self_referencing_column_name, CAST(NULL AS VARCHAR) AS reference_generation, CAST(NULL AS VARCHAR) AS user_defined_type_catalog, CAST(NULL AS VARCHAR) AS user_defined_type_schema, CAST(NULL AS VARCHAR) AS user_defined_type_name, 'YES' AS is_insertable_into, 'NO' AS is_typed, CASE  WHEN ("temporary") THEN ('PRESERVE') ELSE NULL END AS commit_action, "comment" AS TABLE_COMMENT FROM duckdb_tables()) UNION ALL (SELECT database_name AS table_catalog, schema_name AS table_schema, view_name AS table_name, 'VIEW' AS table_type, NULL AS self_referencing_column_name, NULL AS reference_generation, NULL AS user_defined_type_catalog, NULL AS user_defined_type_schema, NULL AS user_defined_type_name, 'NO' AS is_insertable_into, 'NO' AS is_typed, NULL AS commit_action, "comment" AS TABLE_COMMENT FROM duckdb_views);
 CREATE
TEMP VIEW information_schema."views" AS
SELECT database_name AS table_catalog,
       schema_name   AS table_schema,
       view_name     AS table_name,
       "sql"         AS view_definition,
       'NONE'        AS check_option,
       'NO'          AS is_updatable,
       'NO'          AS is_insertable_into,
       'NO'          AS is_trigger_updatable,
       'NO'          AS is_trigger_deletable,
       'NO'          AS is_trigger_insertable_into
FROM duckdb_views();
·
                                                                                                                                       ·                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                                                                                       ·                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
 CREATE
TEMP VIEW pg_catalog.pg_tables AS
SELECT schema_name          AS schemaname,
       table_name           AS tablename,
       'duckdb'             AS tableowner,
       NULL                 AS "tablespace",
       (index_count > 0)    AS hasindexes,
       CAST('f' AS BOOLEAN) AS hasrules,
       CAST('f' AS BOOLEAN) AS hastriggers
FROM duckdb_tables();
CREATE
TEMP VIEW pg_catalog.pg_tablespace AS
SELECT 0 AS oid, 'pg_default' AS spcname, 0 AS spcowner, NULL AS spcacl, NULL AS spcoptions;
CREATE
TEMP VIEW pg_catalog.pg_type AS
SELECT CASE
           WHEN ((type_oid IS NULL)) THEN (NULL)
           WHEN (((logical_type = 'ENUM') AND (type_name != 'enum'))) THEN (type_oid)
           ELSE map_to_pg_oid(type_name) END                       AS oid,
       format_pg_type(logical_type, type_name)                     AS typname,
       schema_oid                                                  AS typnamespace,
       0                                                           AS typowner,
       type_size                                                   AS typlen,
       CAST('f' AS BOOLEAN)                                        AS typbyval,
       CASE WHEN ((logical_type = 'ENUM')) THEN ('e') ELSE 'b' END AS typtype,
       CASE
           WHEN ((type_category = 'NUMERIC')) THEN ('N')
           WHEN ((type_category = 'STRING')) THEN ('S')
           WHEN ((type_category = 'DATETIME')) THEN ('D')
           WHEN ((type_category = 'BOOLEAN')) THEN ('B')
           WHEN ((type_category = 'COMPOSITE')) THEN ('C')
           WHEN ((type_category = 'USER')) THEN ('U')
           ELSE 'X' END                                            AS typcategory,
       CAST('f' AS BOOLEAN)                                        AS typispreferred,
       CAST('t' AS BOOLEAN)                                        AS typisdefined,
       NULL                                                        AS typdelim,
       NULL                                                        AS typrelid,
       NULL                                                        AS typsubscript,
       NULL                                                        AS typelem,
       NULL                                                        AS typarray,
       NULL                                                        AS typinput,
       NULL                                                        AS typoutput,
       NULL                                                        AS typreceive,
       NULL                                                        AS typsend,
       NULL                                                        AS typmodin,
       NULL                                                        AS typmodout,
       NULL                                                        AS typanalyze,
       'd'                                                         AS typalign,
       'p'                                                         AS typstorage,
       NULL                                                        AS typnotnull,
       NULL                                                        AS typbasetype,
       NULL                                                        AS typtypmod,
       NULL                                                        AS typndims,
       NULL                                                        AS typcollation,
       NULL                                                        AS typdefaultbin,
       NULL                                                        AS typdefault,
       NULL                                                        AS typacl
FROM duckdb_types()
WHERE (type_oid IS NOT NULL);
CREATE
TEMP VIEW pg_catalog.pg_views AS
SELECT schema_name AS schemaname, view_name AS viewname, 'duckdb' AS viewowner, "sql" AS definition
FROM duckdb_views();
CREATE
TEMP VIEW pragma_database_list AS
SELECT database_oid AS seq, database_name AS "name", path AS file
FROM duckdb_databases()
WHERE (NOT internal)
ORDER BY 1;
CREATE
TEMP VIEW sqlite_master AS (SELECT 'table' AS "type", table_name AS "name", table_name AS tbl_name, 0 AS rootpage, "sql" FROM duckdb_tables) UNION ALL (SELECT 'view' AS "type", view_name AS "name", view_name AS tbl_name, 0 AS rootpage, "sql" FROM duckdb_views)UNION ALL (SELECT 'index' AS "type", index_name AS "name", table_name AS tbl_name, 0 AS rootpage, "sql" FROM duckdb_indexes);
 CREATE
TEMP VIEW sqlite_schema AS
SELECT *
FROM sqlite_master;
CREATE
TEMP VIEW sqlite_temp_master AS
SELECT *
FROM sqlite_master;
CREATE
TEMP VIEW sqlite_temp_schema AS
SELECT *
FROM sqlite_master;
CREATE UNIQUE INDEX keywords_norm_uq ON keywords (keyword_norm);
CREATE UNIQUE INDEX people_id_pk ON people (id);
CREATE UNIQUE INDEX people_name_year_pk ON people ("name", year_born);
CREATE UNIQUE INDEX people_name_year_uq ON people ("name", year_born);
CREATE UNIQUE INDEX people_pk ON people (id);
CREATE UNIQUE INDEX thesis_id_pk ON thesis (id);
CREATE UNIQUE INDEX thesis_keywords_uq ON thesis_keywords (thesis_id, keyword_id);
CREATE UNIQUE INDEX thesis_people_pk ON thesis_people (thesis_id, person_id, "role");
CREATE UNIQUE INDEX thesis_people_uq ON thesis_people (thesis_id, person_id, "role");
CREATE VIEW v_thesis AS
SELECT id, date_accepted, title, authors, ('https://skemman.is/handle/1946/' || id) AS item_url
FROM thesis;
CREATE VIEW v_thesis_metadata AS
WITH author_lists AS (SELECT tp.thesis_id, array_agg(p."name" ORDER BY tp.sort_order) AS authors
                      FROM thesis_people AS tp
                               INNER JOIN people AS p ON ((p.id = tp.person_id))
                      WHERE (tp."role" = 'author')
                      GROUP BY tp.thesis_id),
     advisor_lists AS (SELECT tp.thesis_id, array_agg(p."name" ORDER BY tp.sort_order) AS advisors
                       FROM thesis_people AS tp
                                INNER JOIN people AS p ON ((p.id = tp.person_id))
                       WHERE (tp."role" = 'advisor')
                       GROUP BY tp.thesis_id),
     keyword_lists AS (SELECT tk.thesis_id, array_agg(k.keyword) AS keywords
                       FROM thesis_keywords AS tk
                                INNER JOIN keywords AS k ON ((k.id = tk.keyword_id))
                       GROUP BY tk.thesis_id)
SELECT m.*, a.authors, ad.advisors, k.keywords
FROM thesis_metadata AS m
         LEFT JOIN author_lists AS a ON ((a.thesis_id = m.thesis_id))
         LEFT JOIN advisor_lists AS ad ON ((ad.thesis_id = m.thesis_id))
         LEFT JOIN keyword_lists AS k ON ((k.thesis_id = m.thesis_id));
65 rows (40 shown)

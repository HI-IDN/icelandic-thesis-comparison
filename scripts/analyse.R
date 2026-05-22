library(DBI)
library(duckdb)
library(dplyr)
library(ggplot2)
library(scales)

# Connect to DuckDB
con <- dbConnect(
  duckdb::duckdb(),
  dbdir = "data/processed/thesis.db",
  read_only = TRUE
)

# Load thesis counts by year and institution
df <- dbGetQuery(con, "
    select
        year(t.date_accepted) as year,
        coalesce(m.university, 'Unknown') as university,
        coalesce(m.degree_level, 'unknown') as degree_level,
        count(*) as thesis_count
    from thesis t
    left join thesis_metadata m
        on m.thesis_id = t.id
    where t.date_accepted is not null
    and m.degree_level in ('bachelor', 'master')
    group by 1, 2, 3
    order by 1, 2, 3
")

# Disconnect
dbDisconnect(con, shutdown = TRUE)

# Plot
ggplot(df, aes(x = year, y = thesis_count, color = university)) +
    geom_line(linewidth = 1) +
    geom_point(size = 2) +

    facet_wrap(~ degree_level, ncol = 1) +

    scale_y_continuous(labels = comma) +

    labs(
        title = "Thesis Count per Year by Institution",
        subtitle = "Faceted by degree level",
        x = "Year",
        y = "Number of theses",
        color = "Institution"
    ) +

    theme_minimal(base_size = 14)

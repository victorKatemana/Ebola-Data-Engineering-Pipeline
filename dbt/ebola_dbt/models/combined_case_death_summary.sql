-- models/combined_case_death_summary.sql
WITH base AS (
    SELECT
        country,
        date,
        indicator,
        SAFE_CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Cumulative number of confirmed, probable and suspected Ebola cases',
        'Cumulative number of confirmed, probable and suspected Ebola deaths'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Cumulative number of confirmed, probable and suspected Ebola cases' THEN value ELSE 0 END) AS total_cases,
        SUM(CASE WHEN indicator = 'Cumulative number of confirmed, probable and suspected Ebola deaths' THEN value ELSE 0 END) AS total_deaths
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted
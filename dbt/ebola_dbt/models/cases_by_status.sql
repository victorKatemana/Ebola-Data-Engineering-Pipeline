-- models/cases_by_status.sql
WITH base AS (
    SELECT
        country,
        date,
        indicator,
        SAFE_CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Cumulative number of confirmed Ebola cases',
        'Cumulative number of probable Ebola cases',
        'Cumulative number of suspected Ebola cases'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Cumulative number of confirmed Ebola cases' THEN value ELSE 0 END) AS confirmed,
        SUM(CASE WHEN indicator = 'Cumulative number of probable Ebola cases' THEN value ELSE 0 END) AS probable,
        SUM(CASE WHEN indicator = 'Cumulative number of suspected Ebola cases' THEN value ELSE 0 END) AS suspected
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted

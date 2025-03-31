{{ config(
    materialized='table',
    partition_by={
        "field": "date",
        "data_type": "date"
    },
    clustering=["country"]
) }}

WITH base AS (
    SELECT
        country,
        CAST(date AS DATE) AS date,
        indicator,
        CAST(CAST(value AS FLOAT64) AS INT64) AS value
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
        SUM(CASE WHEN indicator = 'Cumulative number of confirmed Ebola cases' THEN value ELSE 0 END) AS confirmed_cases,
        SUM(CASE WHEN indicator = 'Cumulative number of probable Ebola cases' THEN value ELSE 0 END) AS probable_cases,
        SUM(CASE WHEN indicator = 'Cumulative number of suspected Ebola cases' THEN value ELSE 0 END) AS suspected_cases
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted

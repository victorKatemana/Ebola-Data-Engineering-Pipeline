WITH base AS (
    SELECT
        country,
        date,
        indicator,
        CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Cumulative number of confirmed Ebola deaths',
        'Cumulative number of probable Ebola deaths',
        'Cumulative number of suspected Ebola deaths'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Cumulative number of confirmed Ebola deaths' THEN value ELSE 0 END) AS confirmed_deaths,
        SUM(CASE WHEN indicator = 'Cumulative number of probable Ebola deaths' THEN value ELSE 0 END) AS probable_deaths,
        SUM(CASE WHEN indicator = 'Cumulative number of suspected Ebola deaths' THEN value ELSE 0 END) AS suspected_deaths
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted
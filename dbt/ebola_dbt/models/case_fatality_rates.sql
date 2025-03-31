-- models/case_fatality_rates.sql
SELECT
    country,
    date,
    indicator,
    SAFE_CAST(value AS FLOAT64) AS cfr
FROM {{ source('ebola', 'ebola_cases') }}
WHERE indicator LIKE 'Case fatality rate (CFR)%';

-- models/death_summary_by_period.sql
WITH base AS (
    SELECT
        country,
        date,
        indicator,
        SAFE_CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Number of confirmed Ebola deaths in the last 21 days',
        'Number of probable Ebola deaths in the last 21 days',
        'Number of suspected Ebola deaths in the last 21 days',
        'Number of confirmed, probable and suspected Ebola deaths in the last 21 days'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Number of confirmed Ebola deaths in the last 21 days' THEN value ELSE 0 END) AS confirmed_deaths,
        SUM(CASE WHEN indicator = 'Number of probable Ebola deaths in the last 21 days' THEN value ELSE 0 END) AS probable_deaths,
        SUM(CASE WHEN indicator = 'Number of suspected Ebola deaths in the last 21 days' THEN value ELSE 0 END) AS suspected_deaths,
        SUM(CASE WHEN indicator = 'Number of confirmed, probable and suspected Ebola deaths in the last 21 days' THEN value ELSE 0 END) AS total_recent_deaths
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted
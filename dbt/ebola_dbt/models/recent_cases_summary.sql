-- models/recent_cases_summary.sql
WITH filtered AS (
    SELECT
        country,
        date,
        indicator,
        SAFE_CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Number of confirmed Ebola cases in the last 7 days',
        'Number of confirmed Ebola cases in the last 21 days',
        'Proportion of confirmed Ebola cases that are from the last 7 days',
        'Proportion of confirmed Ebola cases that are from the last 21 days'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Number of confirmed Ebola cases in the last 7 days' THEN value ELSE 0 END) AS confirmed_7d,
        SUM(CASE WHEN indicator = 'Number of confirmed Ebola cases in the last 21 days' THEN value ELSE 0 END) AS confirmed_21d,
        SUM(CASE WHEN indicator = 'Proportion of confirmed Ebola cases that are from the last 7 days' THEN value ELSE 0 END) AS prop_7d,
        SUM(CASE WHEN indicator = 'Proportion of confirmed Ebola cases that are from the last 21 days' THEN value ELSE 0 END) AS prop_21d
    FROM filtered
    GROUP BY country, date
)

SELECT * FROM pivoted

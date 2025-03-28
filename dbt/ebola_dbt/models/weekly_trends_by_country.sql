WITH base AS (
    SELECT
        country,
        date,
        indicator,
        CAST(value AS INT64) AS value
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Number of confirmed Ebola cases in the last 7 days',
        'Number of probable Ebola cases in the last 7 days',
        'Number of suspected Ebola cases in the last 7 days',
        'Number of confirmed Ebola cases in the last 21 days',
        'Number of probable Ebola cases in the last 21 days',
        'Number of suspected Ebola cases in the last 21 days'
    )
),

pivoted AS (
    SELECT
        country,
        date,
        SUM(CASE WHEN indicator = 'Number of confirmed Ebola cases in the last 7 days' THEN value ELSE 0 END) AS last_7d_confirmed,
        SUM(CASE WHEN indicator = 'Number of probable Ebola cases in the last 7 days' THEN value ELSE 0 END) AS last_7d_probable,
        SUM(CASE WHEN indicator = 'Number of suspected Ebola cases in the last 7 days' THEN value ELSE 0 END) AS last_7d_suspected,
        SUM(CASE WHEN indicator = 'Number of confirmed Ebola cases in the last 21 days' THEN value ELSE 0 END) AS last_21d_confirmed,
        SUM(CASE WHEN indicator = 'Number of probable Ebola cases in the last 21 days' THEN value ELSE 0 END) AS last_21d_probable,
        SUM(CASE WHEN indicator = 'Number of suspected Ebola cases in the last 21 days' THEN value ELSE 0 END) AS last_21d_suspected
    FROM base
    GROUP BY country, date
)

SELECT * FROM pivoted

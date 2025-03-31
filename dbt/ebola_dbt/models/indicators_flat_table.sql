-- models/indicator_flat_table.sql
SELECT
    country,
    date,
    indicator,
    SAFE_CAST(value AS FLOAT64) AS value
FROM {{ source('ebola', 'ebola_cases') }}
ORDER BY country, date, indicator

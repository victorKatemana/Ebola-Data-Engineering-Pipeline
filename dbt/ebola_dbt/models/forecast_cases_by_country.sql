{{ config(
    materialized='view'
) }}

WITH base AS (
    SELECT
        country,
        DATE(date) AS date,
        SUM(CAST(value AS INT64)) AS total_cases
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator = 'Cumulative number of confirmed Ebola cases'
    GROUP BY country, date
),

ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY date) AS rn
    FROM base
),

slope_calc AS (
    SELECT
        country,
        COUNT(*) AS n,
        SUM(rn) AS sum_x,
        SUM(total_cases) AS sum_y,
        SUM(rn * total_cases) AS sum_xy,
        SUM(rn * rn) AS sum_xx
    FROM ranked
    GROUP BY country
),

slope_and_intercept AS (
    SELECT
        country,
        -- Simple linear regression slope and intercept
        (n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x) AS slope,
        (sum_y - ((n * sum_xy - sum_x * sum_y) / (n * sum_xx - sum_x * sum_x)) * sum_x) / n AS intercept
    FROM slope_calc
),

forecasted AS (
    SELECT
        r.country,
        DATE_ADD(MAX(r.date), INTERVAL offset WEEK) AS forecast_date,
        ROUND(s.intercept + s.slope * (MAX(r.rn) + offset)) AS projected_cases
    FROM ranked r
    JOIN slope_and_intercept s
    ON r.country = s.country
    CROSS JOIN UNNEST(GENERATE_ARRAY(1, 4)) AS offset  -- Forecast 4 weeks ahead
    GROUP BY r.country, offset, s.intercept, s.slope
)

SELECT * FROM forecasted

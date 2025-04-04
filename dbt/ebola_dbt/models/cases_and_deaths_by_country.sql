WITH cases AS (
    SELECT
        country,
        date,
        SUM(CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)) AS total_case_value,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of confirmed Ebola cases' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS confirmed_cases,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of probable Ebola cases' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS probable_cases,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of suspected Ebola cases' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS suspected_cases
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Cumulative number of confirmed Ebola cases',
        'Cumulative number of probable Ebola cases',
        'Cumulative number of suspected Ebola cases'
    )
    GROUP BY country, date
),

deaths AS (
    SELECT
        country,
        date,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of confirmed Ebola deaths' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS confirmed_deaths,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of probable Ebola deaths' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS probable_deaths,
        SUM(CASE 
                WHEN indicator = 'Cumulative number of suspected Ebola deaths' 
                THEN CAST(REGEXP_REPLACE(CAST(value AS STRING), r'\.0$', '') AS INT64)
                ELSE 0
            END) AS suspected_deaths
    FROM {{ source('ebola', 'ebola_cases') }}
    WHERE indicator IN (
        'Cumulative number of confirmed Ebola deaths',
        'Cumulative number of probable Ebola deaths',
        'Cumulative number of suspected Ebola deaths'
    )
    GROUP BY country, date
)

SELECT
    c.country,
    c.date,
    confirmed_cases,
    probable_cases,
    suspected_cases,
    confirmed_deaths,
    probable_deaths,
    suspected_deaths
FROM cases c
LEFT JOIN deaths d
ON c.country = d.country AND c.date = d.date

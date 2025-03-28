SELECT
  date,
  SUM(confirmed_cases) AS total_confirmed,
  SUM(probable_cases) AS total_probable,
  SUM(suspected_cases) AS total_suspected
FROM {{ ref('cases_by_country') }}
GROUP BY date
ORDER BY date

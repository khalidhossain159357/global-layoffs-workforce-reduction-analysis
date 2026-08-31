-- Question 1: Which companies experienced repeated rounds of layoffs, and how much time passed between them?

WITH distinct_layoff_events AS (
  SELECT DISTINCT
    company,
    country,
    industry,
    date
  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
),

layoff_history AS (
  SELECT
    company,
    country,
    industry,
    date,

    LAG(date) OVER (
      PARTITION BY company, country, industry
      ORDER BY date
    ) AS previous_layoff_date

  FROM distinct_layoff_events
),

company_summary AS (
  SELECT
    company,
    country,
    industry,

    COUNT(*) AS layoff_event_count,

    MIN(date) AS first_layoff_date,
    MAX(date) AS latest_layoff_date,

    ROUND(
      AVG(DATE_DIFF(date, previous_layoff_date, DAY)),
      1
    ) AS avg_days_between_layoffs

  FROM layoff_history

  GROUP BY
    company,
    country,
    industry
)

SELECT
  company,
  country,
  industry,
  layoff_event_count,
  first_layoff_date,
  latest_layoff_date,
  avg_days_between_layoffs,

  CASE
    WHEN layoff_event_count = 1 THEN 'One-time layoff'
    WHEN layoff_event_count = 2 THEN 'Repeat layoffs'
    ELSE 'Multiple layoff rounds'
  END AS layoff_pattern

FROM company_summary

ORDER BY
  layoff_event_count DESC,
  company;

-- Validation: Are there multiple records for the same company on the same layoff date?

SELECT
  company,
  country,
  industry,
  date,

  COUNT(*) AS records_on_same_date,

  ARRAY_AGG(total_laid_off IGNORE NULLS)
    AS reported_layoff_counts,

  ARRAY_AGG(percentage_laid_off IGNORE NULLS)
    AS reported_layoff_percentages

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

GROUP BY
  company,
  country,
  industry,
  date

HAVING COUNT(*) > 1

ORDER BY
  company,
  date;

-- Question 2: Were layoffs usually one-time events or repeated across multiple rounds?

WITH distinct_layoff_events AS (
  SELECT DISTINCT
    company,
    country,
    industry,
    date
  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
),

company_events AS (
  SELECT
    company,
    country,
    industry,
    COUNT(*) AS layoff_event_count

  FROM distinct_layoff_events

  GROUP BY
    company,
    country,
    industry
)

SELECT
  CASE
    WHEN layoff_event_count = 1 THEN 'One-time layoff'
    WHEN layoff_event_count = 2 THEN 'Repeat layoffs'
    ELSE 'Multiple layoff rounds'
  END AS layoff_pattern,

  COUNT(*) AS companies

FROM company_events

GROUP BY
  layoff_pattern

ORDER BY
  companies DESC;
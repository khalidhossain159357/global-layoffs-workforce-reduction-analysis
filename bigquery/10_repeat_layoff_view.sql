-- Create a reusable company-level repeat layoff summary for dashboard reporting

CREATE OR REPLACE VIEW
  `portfolio-data-lab.global_workforce_restructuring.vw_repeat_layoff_summary` AS

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

FROM company_summary;
-- Create analysis-ready features for time and layoff severity

CREATE OR REPLACE TABLE
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features` AS

SELECT
  company,
  location,
  total_laid_off,
  date,
  percentage_laid_off,
  industry,
  source,
  stage,
  funds_raised,
  country,
  date_added,

  -- Time dimensions
  EXTRACT(YEAR FROM date) AS layoff_year,
  EXTRACT(QUARTER FROM date) AS layoff_quarter,
  EXTRACT(MONTH FROM date) AS layoff_month,
  FORMAT_DATE('%Y-%m', date) AS year_month,

  -- Layoff severity
  CASE
    WHEN percentage_laid_off IS NULL THEN 'Unknown'
    WHEN percentage_laid_off < 0.10 THEN 'Low'
    WHEN percentage_laid_off < 0.25 THEN 'Moderate'
    WHEN percentage_laid_off < 0.50 THEN 'High'
    WHEN percentage_laid_off < 1 THEN 'Severe'
    WHEN percentage_laid_off = 1 THEN 'Full Workforce Reduction'
  END AS severity_category,

  -- Funding range
  CASE
    WHEN funds_raised IS NULL THEN 'Unknown'
    WHEN funds_raised < 50 THEN 'Under $50M'
    WHEN funds_raised < 100 THEN '$50M–$99M'
    WHEN funds_raised < 500 THEN '$100M–$499M'
    WHEN funds_raised < 1000 THEN '$500M–$999M'
    ELSE '$1B+'
  END AS funding_range,
  CASE
    WHEN funds_raised IS NULL THEN 6
    WHEN funds_raised < 50 THEN 1
    WHEN funds_raised < 100 THEN 2
    WHEN funds_raised < 500 THEN 3
    WHEN funds_raised < 1000 THEN 4
    ELSE 5
  END AS funding_order

FROM
  `portfolio-data-lab.global_workforce_restructuring.clean_layoffs`;

-- Validation 1: Does the feature table contain the expected number of rows?

SELECT
  COUNT(*) AS total_rows
FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`;

-- Validation 2: How are layoff records distributed across severity categories?

SELECT
  severity_category,
  COUNT(*) AS record_count
FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
GROUP BY
  severity_category
ORDER BY
  record_count DESC;

-- Validation: Are there company names that differ only by capitalization?

SELECT
  LOWER(company) AS normalized_company,
  COUNT(DISTINCT company) AS name_variations,
  STRING_AGG(
    DISTINCT company,
    ' | '
    ORDER BY company
  ) AS variations
FROM
  `portfolio-data-lab.global_workforce_restructuring.clean_layoffs`
GROUP BY
  LOWER(company)
HAVING
  COUNT(DISTINCT company) > 1;
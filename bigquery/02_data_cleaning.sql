-- Create a cleaned layoffs table with standardized text values and duplicate events removed

CREATE OR REPLACE TABLE
  `portfolio-data-lab.global_workforce_restructuring.clean_layoffs` AS

WITH standardized AS (
  SELECT
    CASE
      WHEN LOWER(TRIM(company)) = 'clearco' THEN 'ClearCo'
      WHEN LOWER(TRIM(company)) = 'butterfly network copy' THEN 'Butterfly Network'
      WHEN LOWER(TRIM(company)) = 'sage therapeutics copy' THEN 'Sage Therapeutics'
      WHEN LOWER(TRIM(company)) = 'loop' THEN 'Loop'
      WHEN LOWER(TRIM(company)) = 'freshbooks' THEN 'FreshBooks'
      WHEN LOWER(TRIM(company)) = 'uipath' THEN 'UiPath'
      WHEN LOWER(TRIM(company)) = 'appgate' THEN 'AppGate'
      WHEN LOWER(TRIM(company)) = '7shifts' THEN '7shifts'
      WHEN LOWER(TRIM(company)) = 'salesloft' THEN 'SalesLoft'
      WHEN LOWER(TRIM(company)) = 'mara' THEN 'MARA'
      ELSE TRIM(company)
    END AS company,

    TRIM(location) AS location,
    total_laid_off,
    date,
    percentage_laid_off,
    TRIM(industry) AS industry,
    TRIM(source) AS source,
    TRIM(stage) AS stage,
    funds_raised,

    CASE
      WHEN TRIM(country) = 'UAE' THEN 'United Arab Emirates'
      ELSE TRIM(country)
    END AS country,

    date_added

  FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`
),

deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY
        company,
        location,
        CAST(total_laid_off AS NUMERIC),
        date,
        CAST(percentage_laid_off AS NUMERIC),
        industry,
        stage,
        CAST(funds_raised AS NUMERIC),
        country
      ORDER BY date_added
    ) AS row_num

  FROM standardized
)

SELECT
  * EXCEPT(row_num)
FROM deduplicated
WHERE row_num = 1;

-- Validation 1: How many rows remain after cleaning?

SELECT 
    COUNT(*) AS total_rows
FROM
    `portfolio-data-lab.global_workforce_restructuring.clean_layoffs`;

-- Validation 2: Are any duplicate events still present?

SELECT 
    company,
    location,
    total_laid_off,
    date,
    percentage_laid_off,
    industry,
    stage,
    funds_raised,
    country,
    COUNT(*) AS event_count
FROM
    `portfolio-data-lab.global_workforce_restructuring.clean_layoffs`
GROUP BY company , location , total_laid_off , date , percentage_laid_off , industry , stage , funds_raised , country
HAVING COUNT(*) > 1;

-- Validation 3: Did cleaning create any unexpected blank text values?

SELECT 
    COUNTIF(company IS NULL OR TRIM(company) = '') AS missing_company,
    COUNTIF(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    COUNTIF(country IS NULL OR TRIM(country) = '') AS missing_country,
    COUNTIF(stage IS NULL OR TRIM(stage) = '') AS missing_stage
FROM
    `portfolio-data-lab.global_workforce_restructuring.clean_layoffs`;
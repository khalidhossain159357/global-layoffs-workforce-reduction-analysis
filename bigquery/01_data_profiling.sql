-- 1: How large is the raw dataset and what period does it cover?

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT company) AS unique_companies,
    MIN(date) AS earliest_layoff_date,
    MAX(date) AS latest_layoff_date
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 2: Which columns contain missing values?

SELECT 
    COUNTIF(company IS NULL OR TRIM(company) = '') AS missing_company,
    COUNTIF(location IS NULL OR TRIM(location) = '') AS missing_location,
    COUNTIF(total_laid_off IS NULL) AS missing_total_laid_off,
    COUNTIF(date IS NULL) AS missing_date,
    COUNTIF(percentage_laid_off IS NULL) AS missing_percentage_laid_off,
    COUNTIF(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    COUNTIF(source IS NULL OR TRIM(source) = '') AS missing_source,
    COUNTIF(stage IS NULL OR TRIM(stage) = '') AS missing_stage,
    COUNTIF(funds_raised IS NULL) AS missing_funds_raised,
    COUNTIF(country IS NULL OR TRIM(country) = '') AS missing_country,
    COUNTIF(date_added IS NULL) AS missing_date_added
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 3: Are there any invalid numeric values?

SELECT 
    COUNTIF(total_laid_off < 0) AS negative_layoffs,
    COUNTIF(total_laid_off = 0) AS zero_layoffs,
    COUNTIF(funds_raised < 0) AS negative_funding,
    COUNTIF(percentage_laid_off < 0) AS percentage_below_zero,
    COUNTIF(percentage_laid_off > 1) AS percentage_above_one,
    COUNTIF(percentage_laid_off = 1) AS full_workforce_reductions
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 4: How often are layoff count and layoff percentage reported?

SELECT 
    COUNTIF(total_laid_off IS NOT NULL
                AND percentage_laid_off IS NOT NULL) AS both_metrics_available,
    COUNTIF(total_laid_off IS NOT NULL
                AND percentage_laid_off IS NULL) AS only_layoff_count_available,
    COUNTIF(total_laid_off IS NULL
                AND percentage_laid_off IS NOT NULL) AS only_layoff_percentage_available,
    COUNTIF(total_laid_off IS NULL
                AND percentage_laid_off IS NULL) AS neither_metric_available
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 5: Are there any unusual or invalid dates?

SELECT 
    COUNTIF(date IS NULL) AS missing_layoff_dates,
    COUNTIF(date > CURRENT_DATE()) AS future_layoff_dates,
    COUNTIF(date_added IS NULL) AS missing_date_added,
    COUNTIF(date_added IS NOT NULL
                AND date IS NOT NULL
                AND date_added < date) AS records_added_before_layoff_date
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 6: What are the basic ranges of the main numeric fields?

SELECT
  MIN(total_laid_off) AS min_laid_off,
  MAX(total_laid_off) AS max_laid_off,
  ROUND(AVG(total_laid_off), 2) AS avg_laid_off,
  APPROX_QUANTILES(total_laid_off, 2)[OFFSET(1)] AS median_laid_off,

  MIN(percentage_laid_off) AS min_layoff_percentage,
  MAX(percentage_laid_off) AS max_layoff_percentage,
  ROUND(AVG(percentage_laid_off), 4) AS avg_layoff_percentage,
  APPROX_QUANTILES(
    percentage_laid_off,
    2
  )[OFFSET(1)] AS median_layoff_percentage,

  MIN(funds_raised) AS min_funding,
  MAX(funds_raised) AS max_funding,
  ROUND(AVG(funds_raised), 2) AS avg_funding,
  APPROX_QUANTILES(
    funds_raised,
    2
  )[OFFSET(1)] AS median_funding

FROM
  `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`;


-- Question 7: What does the raw imported data look like?

SELECT 
    *
FROM
    `portfolio-data-lab.global_workforce_restructuring.raw_layoffs`
LIMIT 20;
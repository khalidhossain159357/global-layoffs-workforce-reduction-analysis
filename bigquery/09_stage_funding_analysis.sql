-- Question 1: Which company stages reported the highest total layoffs?

SELECT 
    stage, SUM(total_laid_off) AS total_layoffs
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
        AND stage IS NOT NULL
GROUP BY stage
ORDER BY total_layoffs DESC;

-- Question 2: Which company stages experienced the most layoff events?

SELECT
  stage,

  COUNT(DISTINCT CONCAT(
    company, '|',
    country, '|',
    industry, '|',
    CAST(date AS STRING)
  )) AS layoff_events

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

WHERE
  stage IS NOT NULL
  AND date IS NOT NULL

GROUP BY
  stage

ORDER BY
  layoff_events DESC;

-- Question 3: What is the average reported workforce reduction percentage by company stage?

SELECT 
    stage,
    COUNT(percentage_laid_off) AS reported_percentage_events,
    ROUND(AVG(percentage_laid_off) * 100, 2) AS avg_layoff_percentage
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    percentage_laid_off IS NOT NULL
        AND stage IS NOT NULL
GROUP BY stage
HAVING COUNT(percentage_laid_off) >= 5
ORDER BY avg_layoff_percentage DESC;

-- Question 4: How do reported layoffs vary across funding ranges?

WITH funding_groups AS (
  SELECT
    total_laid_off,

    CASE
      WHEN funds_raised IS NULL THEN 'Unknown'
      WHEN funds_raised < 50 THEN 'Under $50M'
      WHEN funds_raised < 100 THEN '$50M–$99M'
      WHEN funds_raised < 500 THEN '$100M–$499M'
      WHEN funds_raised < 1000 THEN '$500M–$999M'
      ELSE '$1B+'
    END AS funding_range

  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
)

SELECT
  funding_range,
  COUNT(*) AS records,
  COUNT(total_laid_off) AS records_with_layoff_count,
  SUM(total_laid_off) AS total_layoffs,
  ROUND(AVG(total_laid_off), 1) AS avg_layoffs_per_record

FROM
  funding_groups

GROUP BY
  funding_range

ORDER BY
  CASE funding_range
    WHEN 'Under $50M' THEN 1
    WHEN '$50M–$99M' THEN 2
    WHEN '$100M–$499M' THEN 3
    WHEN '$500M–$999M' THEN 4
    WHEN '$1B+' THEN 5
    WHEN 'Unknown' THEN 6
  END;
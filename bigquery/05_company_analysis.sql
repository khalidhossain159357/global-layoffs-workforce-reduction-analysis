-- Question 1: Which companies reported the highest total layoffs?

SELECT 
    company,
    country,
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
GROUP BY company , country , industry
ORDER BY total_layoffs DESC;

-- Question 2: What were the largest individual layoff events?

SELECT 
    company,
    country,
    industry,
    date,
    total_laid_off,
    percentage_laid_off,
    stage
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC;

-- Question 3: Which companies had the highest average workforce reduction percentage across multiple reported events?

SELECT 
    company,
    country,
    industry,
    COUNT(percentage_laid_off) AS reported_percentage_events,
    ROUND(AVG(percentage_laid_off) * 100, 2) AS avg_layoff_percentage
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    percentage_laid_off IS NOT NULL
GROUP BY company , country , industry
HAVING COUNT(percentage_laid_off) >= 2
ORDER BY avg_layoff_percentage DESC;

-- Question 4: Which companies reported the most layoffs in each year?

WITH company_year AS (
  SELECT
    layoff_year,
    company,
    country,
    industry,
    SUM(total_laid_off) AS total_layoffs
  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
  WHERE
    total_laid_off IS NOT NULL
    AND layoff_year IS NOT NULL
  GROUP BY
    layoff_year,
    company,
    country,
    industry
),

ranked_companies AS (
  SELECT
    *,
    DENSE_RANK() OVER (
      PARTITION BY layoff_year
      ORDER BY total_layoffs DESC
    ) AS layoff_rank
  FROM company_year
)

SELECT
  layoff_year,
  company,
  country,
  industry,
  total_layoffs,
  layoff_rank
FROM
  ranked_companies
WHERE
  layoff_rank <= 5
ORDER BY
  layoff_year,
  layoff_rank,
  total_layoffs DESC;
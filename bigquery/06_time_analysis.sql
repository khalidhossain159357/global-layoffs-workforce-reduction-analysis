-- Question 1: How did total layoffs change by year?

SELECT 
    layoff_year, SUM(total_laid_off) AS total_layoffs
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
        AND layoff_year IS NOT NULL
GROUP BY layoff_year
ORDER BY layoff_year;

-- Question 2: How did the number of reported layoff events change by year?

SELECT
  layoff_year,
  COUNT(DISTINCT CONCAT(
    company, '|',
    country, '|',
    industry, '|',
    CAST(date AS STRING)
  )) AS layoff_events

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

WHERE
  layoff_year IS NOT NULL

GROUP BY
  layoff_year

ORDER BY
  layoff_year;

-- Question 3: What was the monthly trend in total layoffs?

SELECT
  year_month,
  SUM(total_laid_off) AS total_layoffs

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

WHERE
  total_laid_off IS NOT NULL
  AND year_month IS NOT NULL

GROUP BY
  year_month

ORDER BY
  year_month;

-- Question 4: What was the cumulative monthly total of reported layoffs?

WITH monthly_summary AS (
  SELECT
    year_month,
    SUM(total_laid_off) AS monthly_layoff_total
  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
  WHERE
    total_laid_off IS NOT NULL
    AND year_month IS NOT NULL
  GROUP BY
    year_month
)

SELECT
  year_month,
  monthly_layoff_total,

  SUM(monthly_layoff_total) OVER (
    ORDER BY year_month
  ) AS cumulative_layoffs

FROM
  monthly_summary

ORDER BY
  year_month;
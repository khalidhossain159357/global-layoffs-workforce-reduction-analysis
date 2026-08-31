-- Question 1: Which industries reported the highest total layoffs?

SELECT 
    industry, SUM(total_laid_off) AS total_layoffs
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
        AND industry IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Question 2: Which industries experienced the most layoff events?

SELECT
  industry,
  COUNT(DISTINCT CONCAT(
    company, '|',
    country, '|',
    CAST(date AS STRING)
  )) AS layoff_events

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

WHERE
  industry IS NOT NULL
  AND date IS NOT NULL

GROUP BY
  industry

ORDER BY
  layoff_events DESC;

-- Question 3: Which industries had the highest average reported workforce reduction percentage?

SELECT 
    industry,
    COUNT(percentage_laid_off) AS reported_percentage_events,
    ROUND(AVG(percentage_laid_off) * 100, 2) AS avg_layoff_percentage
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    percentage_laid_off IS NOT NULL
        AND industry IS NOT NULL
GROUP BY industry
HAVING COUNT(percentage_laid_off) >= 5
ORDER BY avg_layoff_percentage DESC;


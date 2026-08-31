-- Question 1: Which countries reported the highest total layoffs?

SELECT 
    country, SUM(total_laid_off) AS total_layoffs
FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`
WHERE
    total_laid_off IS NOT NULL
        AND country IS NOT NULL
GROUP BY country
ORDER BY total_layoffs DESC;

-- Question 2: Which countries experienced the most layoff events?

SELECT
  country,

  COUNT(DISTINCT CONCAT(
    company, '|',
    industry, '|',
    CAST(date AS STRING)
  )) AS layoff_events

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

WHERE
  country IS NOT NULL
  AND date IS NOT NULL

GROUP BY
  country

ORDER BY
  layoff_events DESC;

-- Question 3: How did layoffs change over time in the countries with the highest overall layoffs?

WITH top_countries AS (
  SELECT
    country,
    SUM(total_laid_off) AS total_layoffs

  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

  WHERE
    total_laid_off IS NOT NULL
    AND country IS NOT NULL

  GROUP BY
    country

  ORDER BY
    total_layoffs DESC

  LIMIT 10
)

SELECT
  l.layoff_year,
  l.country,
  SUM(l.total_laid_off) AS total_layoffs

FROM
  `portfolio-data-lab.global_workforce_restructuring.layoffs_features` AS l

INNER JOIN
  top_countries AS t
ON
  l.country = t.country

WHERE
  l.total_laid_off IS NOT NULL
  AND l.layoff_year IS NOT NULL

GROUP BY
  l.layoff_year,
  l.country

ORDER BY
  l.layoff_year,
  total_layoffs DESC;
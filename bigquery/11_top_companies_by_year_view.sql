-- Create Top 5 companies by total layoffs for each year

CREATE OR REPLACE VIEW
  `portfolio-data-lab.global_workforce_restructuring.vw_top_companies_by_year` AS

WITH company_year AS (
  SELECT
    layoff_year,
    company,
    SUM(total_laid_off) AS total_layoffs

  FROM
    `portfolio-data-lab.global_workforce_restructuring.layoffs_features`

  WHERE
    total_laid_off IS NOT NULL
    AND layoff_year IS NOT NULL

  GROUP BY
    layoff_year,
    company
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
  total_layoffs,
  layoff_rank

FROM ranked_companies

WHERE
  layoff_rank <= 5;
# Ratios of ethnicities grouped by gender
SELECT
  population,
  gender,
  population_count,
  RATIO_TO_REPORT(population_count) OVER(
  PARTITION BY
    population
  ORDER BY
    gender)
  AS population_ratio
from(
  SELECT
    gender,
    population,
    COUNT(population) AS population_count,
  FROM
    [genomics-public-data:1000_genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    gender,
    population)
ORDER BY
  population,
  gender

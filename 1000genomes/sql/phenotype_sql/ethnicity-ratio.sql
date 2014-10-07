# Compute sample count and ratio by ethnicity
SELECT
  population,
  population_description,
  population_count,
  RATIO_TO_REPORT(population_count)
OVER
  (
  ORDER BY
    population_count) AS population_ratio,
  super_population,
  super_population_description,
from(
  SELECT
    population,
    population_description,
    super_population,
    super_population_description,
    COUNT(population) AS population_count,
  FROM
    [genomics-public-data:1000_genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    population,
    population_description,
    super_population,
    super_population_description)

-- We'd like to see how the members of each super population share variation.
--
-- Let's generate a table where the records indicate:
--
-- For the variants that appear in a given super-population:
--  how many variants are singletons (not shared)?
--  how many variants are shared by exactly 2 individuals?
--  how many variants are shared by exactly 3 individuals?
--  etc ...
--  how many variants are shared by all members of the super population?
--
-- The variants and counts are further partitioned by whether the variant is common or rare.
WITH
  population_counts AS (
  SELECT
    super_population,
    COUNT(population) AS super_population_count
  FROM
    `genomics-public-data.1000_genomes.sample_info`
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    super_population),
  --
  autosome_calls AS (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alternate_bases[ORDINAL(1)] AS alt,  -- 1000 Genomes is biallelic.
    vt,
    af IS NOT NULL
    AND af >= 0.05 AS is_common_variant,
    call.call_set_name,
    super_population
  FROM
    `genomics-public-data.1000_genomes.variants` AS v, v.call AS call
  JOIN
    `genomics-public-data.1000_genomes.sample_info` AS p
  ON
    call.call_set_name = p.sample
  WHERE
    reference_name NOT IN ("X", "Y", "MT")
    AND EXISTS (SELECT gt FROM UNNEST(call.genotype) gt WHERE gt > 0)),
  --
  super_population_autosome_variants AS (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant,
    COUNT(call_set_name) AS num_samples
  FROM
    autosome_calls
  GROUP BY
    reference_name,
    start,
    `end`,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant )
  --
  --
SELECT
  p.super_population AS super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  num_samples / super_population_count AS percent_samples,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM
  super_population_autosome_variants AS v
JOIN population_counts AS p
ON
  v.super_population = p.super_population
GROUP BY
  super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  percent_samples
ORDER BY
  num_samples,
  super_population,
  is_common_variant

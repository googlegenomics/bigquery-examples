# COUNT the number of variants shared BY none, shared BY one sample, two samples, etc...
# further grouped by super population and common versus rare variants.
SELECT
  pops.super_population AS super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  num_samples / super_population_count
  AS percent_samples,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM  (
  SELECT
    reference_name,
    start,
    END,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant,
    SUM(has_variant) AS num_samples
  FROM (
      FLATTEN((
        SELECT
          reference_name,
          start,
          END,
          reference_bases,
          GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
          vt,
          af IS NOT NULL AND af >= 0.05 AS is_common_variant,
          call.call_set_name AS sample_id,
          NOT EVERY(call.genotype <= 0) WITHIN call AS has_variant,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name NOT IN ("X", "Y", "MT")),
        call)) AS samples
  JOIN
    [genomics-public-data:1000_genomes.sample_info] p
  ON
    samples.sample_id = p.sample
  GROUP EACH BY
    reference_name,
    start,
    END,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant) AS vars
JOIN (
  SELECT
    super_population,
    COUNT(population) AS super_population_count,
  FROM
    [genomics-public-data:1000_genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    super_population) AS pops
ON
  vars.super_population = pops.super_population
GROUP EACH BY
  super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  percent_samples
ORDER BY
  num_samples,
  super_population,
  is_common_variant

# COUNT the number of variants shared BY none, shared BY one sample, two samples, etc...
# further grouped by super population and common versus rare variants.
SELECT
  pops.super_population AS super_population,
  super_population_count,
  is_common_variant,
  num_samples_in_pop_with_variant_in_category,
  num_samples_in_pop_with_variant_in_category / super_population_count
  AS percent_samples_in_pop_with_variant_in_category,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM
  (
  SELECT
    contig,
    position,
    reference_bases,
    alt,
    vt,
    end,
    super_population,
    IF(af >= 0.05,
      1,
      0) AS is_common_variant,
    SUM(has_variant) AS num_samples_in_pop_with_variant_in_category
  FROM (
    SELECT
      contig,
      position,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      vt,
      end,
      super_population,
      IF(af >= 0.05,
        TRUE,
        FALSE) AS is_common_variant,
      IF(genotype.first_allele > 0
        OR genotype.second_allele > 0,
        1,
        0) AS has_variant
    FROM
      FLATTEN([google.com:biggene:1000genomes.phase1_variants],
        genotype) AS samples
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      samples.genotype.sample_id = p.sample)
    GROUP EACH BY
    contig,
    position,
    reference_bases,
    alt,
    vt,
    end,
    super_population,
    is_common_variant) AS vars
JOIN (
  SELECT
    super_population,
    COUNT(population) AS super_population_count,
  FROM
    [google.com:biggene:1000genomes.sample_info]
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
  num_samples_in_pop_with_variant_in_category,
  percent_samples_in_pop_with_variant_in_category
ORDER BY
  num_samples_in_pop_with_variant_in_category;

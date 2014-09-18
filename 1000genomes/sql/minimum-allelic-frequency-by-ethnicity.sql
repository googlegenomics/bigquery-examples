# Count the variation for each sample including phenotypic traits
SELECT
  samples.genotype.sample_id AS sample_id,
  gender,
  population,
  super_population,
  COUNT(samples.genotype.sample_id) AS num_variants_for_sample,
  SUM(IF(samples.af >= 0.05,
      INTEGER(1),
      INTEGER(0))) AS common_variant,
  SUM(IF(samples.af < 0.05
      AND samples.af > 0.005,
      INTEGER(1),
      INTEGER(0))) AS middle_variant,
  SUM(IF(samples.af <= 0.005
      AND samples.af > 0.001,
      INTEGER(1),
      INTEGER(0))) AS rare_variant,
  SUM(IF(samples.af <= 0.001,
      INTEGER(1),
      INTEGER(0))) AS very_rare_variant,
FROM
  FLATTEN([google.com:biggene:1000genomes.phase1_variants],
    genotype) AS samples
JOIN
  [google.com:biggene:1000genomes.sample_info] p
ON
  samples.genotype.sample_id = p.sample
WHERE
  samples.vt = 'SNP'
  AND (samples.genotype.first_allele > 0
    OR samples.genotype.second_allele > 0)
GROUP BY
  sample_id,
  gender,
  population,
  super_population
ORDER BY
  sample_id;

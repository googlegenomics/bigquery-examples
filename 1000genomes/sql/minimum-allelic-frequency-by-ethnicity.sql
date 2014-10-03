# Count the variation for each sample including phenotypic traits
SELECT
  samples.call.call_set_name AS sample_id,
  gender,
  population,
  super_population,
  COUNT(samples.call.call_set_name) AS num_variants_for_sample,
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
  FLATTEN((
    SELECT
      af,
      vt,
      call.call_set_name,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      vt = 'SNP'
    HAVING
      first_allele > 0
      OR (second_allele IS NOT NULL
          AND second_allele > 0)
      ),
    call) AS samples
JOIN
  [genomics-public-data:1000_genomes.sample_info] p
ON
  samples.call.call_set_name = p.sample
GROUP BY
  sample_id,
  gender,
  population,
  super_population
ORDER BY
  sample_id

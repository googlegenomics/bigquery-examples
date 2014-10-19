# Count the variation for each sample including phenotypic traits but excluding
# sex chromosomes.
SELECT
  samples.call.call_set_name AS sample_id,
  gender,
  population,
  super_population,
  COUNT(samples.call.call_set_name) AS num_variants_for_sample,
  SUM(samples.af >= 0.05) AS common_variant,
  SUM(samples.af < 0.05 AND samples.af > 0.005) AS middle_variant,
  SUM(samples.af <= 0.005 AND samples.af > 0.001) AS rare_variant,
  SUM(samples.af <= 0.001) AS very_rare_variant,
FROM
  FLATTEN((
    SELECT
      af,
      vt,
      call.call_set_name,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      vt = 'SNP'
      AND reference_name != 'X'
      AND reference_name != 'Y'
    OMIT call IF EVERY(call.genotype <= 0)),
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

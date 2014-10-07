# Compute the number of variants within BRCA1 for a particular sample that are shared by
# no other samples.
SELECT
  COUNT(sample_id) AS private_variants_count,
  sample_id
FROM
  (
  SELECT
    reference_name,
    start,
    reference_bases,
    IF(0 < call.genotype,
      call.call_set_name,
      NULL) AS sample_id,
    SUM(IF(0 < call.genotype,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start BETWEEN 41196311
    AND 41277499
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  sample_id

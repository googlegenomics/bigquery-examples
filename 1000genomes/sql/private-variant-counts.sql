# Compute the number of variants for a particular sample that are shared by 
# no other samples.
SELECT
  COUNT(sample_id) AS private_variants_count,
  sample_id
FROM
  (
  SELECT
    contig,
    position,
    reference_bases,
    IF(call.first_allele > 0
      OR call.second_allele > 0,
      call.callset_name,
      NULL) AS sample_id,
    SUM(IF(call.first_allele > 0
        OR call.second_allele > 0,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  private_variants_count DESC;
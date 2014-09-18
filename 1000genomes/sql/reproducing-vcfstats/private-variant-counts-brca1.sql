# Compute the number of variants within BRCA1 for a particular sample that are shared by 
# no other samples.
SELECT
  COUNT(sample_id) AS private_variants_count,
  sample_id
FROM
  (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    IF(0 < call.first_allele
      OR 0 < call.second_allele,
      call.callset_name,
      NULL) AS sample_id,
    SUM(IF(0 < call.first_allele
        OR 0 < call.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
    AND start_pos BETWEEN 41196312
    AND 41277500
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  sample_id
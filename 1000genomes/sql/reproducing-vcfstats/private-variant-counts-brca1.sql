# Compute the number of variants within BRCA1 for a particular sample that are shared by 
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
    IF(0 < genotype.first_allele
      OR 0 < genotype.second_allele,
      genotype.sample_id,
      NULL) AS sample_id,
    SUM(IF(0 < genotype.first_allele
        OR 0 < genotype.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  sample_id;
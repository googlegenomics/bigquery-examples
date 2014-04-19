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
    IF(genotype.first_allele > 0
      OR genotype.second_allele > 0,
      genotype.sample_id,
      NULL) AS sample_id,
    SUM(IF(genotype.first_allele > 0
        OR genotype.second_allele > 0,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  private_variants_count DESC;
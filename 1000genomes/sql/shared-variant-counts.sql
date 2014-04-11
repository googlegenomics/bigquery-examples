SELECT
  num_samples_with_variant,
  COUNT(num_samples_with_variant) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    SUM(IF(0 != genotype.first_allele
        OR 0 != genotype.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG])
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant;
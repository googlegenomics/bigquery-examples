# Count the number of variants shared by none, shared by one sample, shared by 
# two samples, etc... in BRCA1
SELECT
  num_samples_with_variant AS num_shared_variants,
  COUNT(num_samples_with_variant) AS frequency
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    SUM(IF(0 < genotype.first_allele
        OR 0 < genotype.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500)
GROUP BY
  num_shared_variants
ORDER BY
  num_shared_variants;

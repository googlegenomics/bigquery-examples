# Count the number of variants shared by none, shared by one sample, shared by 
# two samples, etc... in BRCA1
SELECT
  num_samples_with_variant AS num_shared_variants,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    SUM(IF(0 < call.first_allele
        OR 0 < call.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
    AND start_pos BETWEEN 41196312
    AND 41277500)
GROUP BY
  num_shared_variants
ORDER BY
  num_shared_variants;

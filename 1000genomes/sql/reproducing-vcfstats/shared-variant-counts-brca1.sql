# Count the number of variants shared by none, shared by one sample, shared by
# two samples, etc... in BRCA1
SELECT
  num_samples_with_variant,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    reference_name,
    start,
    END,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    SUM(NOT EVERY(call.genotype <= 0)) WITHIN call AS num_samples_with_variant
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start BETWEEN 41196311
    AND 41277499
    )
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant
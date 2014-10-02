# Count the number of variants shared by none, shared by one sample, shared by
# two samples, etc... in BRCA1
SELECT
  num_samples_with_variant AS num_shared_variants,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    SUM(first_allele > 0
      OR second_allele > 0) AS num_samples_with_variant
  FROM(
    SELECT
      reference_name,
      start,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      reference_name = '17'
      AND start BETWEEN 41196311
      AND 41277499
      )
  GROUP BY
    reference_name,
    start,
    reference_bases,
    alt
    )
GROUP BY
  num_shared_variants
ORDER BY
  num_shared_variants

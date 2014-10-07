# Count the number of samples that have the BRCA1 variant.
SELECT
  reference_name,
  start,
  reference_bases,
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
      AND vt ='SNP'
      )
  GROUP BY
    reference_name,
    start,
    reference_bases,
    alt
ORDER BY
  num_samples_with_variant,
  start

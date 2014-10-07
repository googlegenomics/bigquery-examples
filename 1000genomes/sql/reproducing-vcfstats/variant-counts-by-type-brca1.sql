# Count the number of variants by type in BRCA1.
SELECT
  vt AS variant_type,
  COUNT(vt) AS num_variants_of_type,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
  AND 41277499
GROUP BY
  variant_type
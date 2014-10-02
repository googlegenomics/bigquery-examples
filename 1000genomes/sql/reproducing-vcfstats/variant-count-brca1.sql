# Count the number of variants in BRCA1
SELECT
  count(reference_name) as num_variants,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
  AND 41277499
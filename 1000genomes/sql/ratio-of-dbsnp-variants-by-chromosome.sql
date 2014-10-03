# Get the proportion of variants that have been reported in the dbSNP database
# version 132 , by chromosome, in the dataset.
SELECT
  reference_name,
  num_dbsnp_variants,
  num_variants,
  num_dbsnp_variants / num_variants frequency
FROM (
  SELECT
    reference_name,
    COUNT(1) AS num_variants,
    SUM(num_dbsnp_ids > 0) AS num_dbsnp_variants,
  FROM (
    SELECT
      reference_name,
      COUNT(names) WITHIN RECORD AS num_dbsnp_ids
    FROM
      [genomics-public-data:1000_genomes.variants]
      )
  GROUP BY
    reference_name
    )
ORDER BY
  num_variants DESC

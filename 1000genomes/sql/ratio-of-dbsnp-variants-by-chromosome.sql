# Get the proportion of variants that have been reported in the dbSNP database
# version 132 , by chromosome, in the dataset.
SELECT
  all_variants.reference_name AS reference_name,
  dbsnp_variants.num_variants AS num_dbsnp_variants,
  all_variants.num_variants AS num_variants,
  dbsnp_variants.num_variants / all_variants.num_variants frequency
FROM (
  SELECT
    reference_name,
    COUNT(*) num_variants
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    names IS NOT NULL
  GROUP BY
    reference_name) dbsnp_variants
JOIN (
  SELECT
    reference_name,
    COUNT(*) num_variants
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name
    ) all_variants
  ON dbsnp_variants.reference_name = all_variants.reference_name
ORDER BY
  all_variants.num_variants DESC

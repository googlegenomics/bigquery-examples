# Get the proportion of variants that have been reported in the dbSNP database 
# version 132 , by chromosome, in the dataset.
SELECT
  all_variants.contig_name AS contig_name,
  dbsnp_variants.num_variants AS num_dbsnp_variants,
  all_variants.num_variants AS num_variants,
  dbsnp_variants.num_variants / all_variants.num_variants frequency
FROM (
  SELECT
    contig_name,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    id IS NOT NULL
  GROUP BY
    contig_name) dbsnp_variants
JOIN (
  SELECT
    contig_name,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    contig_name
    ) all_variants
  ON dbsnp_variants.contig_name = all_variants.contig_name
ORDER BY
  all_variants.num_variants DESC
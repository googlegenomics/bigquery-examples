# Get the proportion of variants that have been reported in the dbSNP database 
# version 132 , by chromosome, in the dataset.
SELECT
  all_variants.contig AS contig,
  dbsnp_variants.num_variants AS num_dbsnp_variants,
  all_variants.num_variants AS num_variants,
  dbsnp_variants.num_variants / all_variants.num_variants frequency
FROM (
  SELECT
    contig,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    id IS NOT NULL
  GROUP BY
    contig) dbsnp_variants
JOIN (
  SELECT
    contig,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    contig
    ) all_variants
  ON dbsnp_variants.contig = all_variants.contig
ORDER BY
  all_variants.num_variants DESC;
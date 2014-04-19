# Get the proportion of variants that have been reported in the dbSNP database 
# version 132 , by chromosome, in the dataset.
SELECT
  variants.contig,
  variants.num_variants,
  total.num_entries,
  variants.num_variants / total.num_entries freq
FROM (
  SELECT
    contig,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    id IS NOT NULL
  GROUP BY
    contig) variants
JOIN (
  SELECT
    contig,
    COUNT(*) num_entries
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  GROUP BY
    contig
    ) total
  ON variants.contig = total.contig
ORDER BY
  total.num_entries DESC;
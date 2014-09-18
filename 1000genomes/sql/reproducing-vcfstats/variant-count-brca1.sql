# Count the number of variants in BRCA1
SELECT
  count(contig_name) as num_variants,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND start_pos BETWEEN 41196312
  AND 41277500
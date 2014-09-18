# Count the number of variants in BRCA1
SELECT
  count(contig) as num_variants,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500;
# Count the number of variants by type in BRCA1.
SELECT
  vt AS variant_type,
  COUNT(vt) AS num_variants_of_type,
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
GROUP BY
  variant_type;
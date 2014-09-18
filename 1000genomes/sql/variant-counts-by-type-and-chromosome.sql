# Count the number of variants across the entirety of 1,000 Genomes by variant type and 
# chromosome.
SELECT
  contig_name,
  vt,
  COUNT(vt) AS cnt,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
GROUP BY
  contig_name,
  vt
ORDER BY
  contig_name,
  vt
# Count the number of variants across the entirety of 1,000 Genomes by variant type.
SELECT
  vt,
  COUNT(vt) as cnt,
FROM
  [genomics-public-data:1000_genomes.variants]
GROUP BY
  vt
ORDER BY
  vt

# Count the number of variants across the entirety of 1,000 Genomes by variant type and
# chromosome.
SELECT
  reference_name,
  vt,
  COUNT(vt) AS cnt,
FROM
  [genomics-public-data:1000_genomes.variants]
GROUP BY
  reference_name,
  vt
ORDER BY
  reference_name,
  vt

SELECT
  contig,
  vt,
  COUNT(vt) AS cnt,
FROM
  [google.com:biggene:1000genomes.variants1kG]
GROUP BY
  contig,
  vt
ORDER BY
  contig,
  vt;
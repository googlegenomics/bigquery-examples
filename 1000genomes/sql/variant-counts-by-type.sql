SELECT
  vt,
  COUNT(vt) as cnt,
FROM
  [google.com:biggene:1000genomes.variants1kG]
GROUP BY
  vt
ORDER BY
  vt;

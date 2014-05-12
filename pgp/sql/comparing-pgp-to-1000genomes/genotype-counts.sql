# Count the number of sample genotypes.
SELECT
  call.gt,
  COUNT(call.gt) AS cnt
FROM
  [google.com:biggene:pgp.variants]
GROUP BY
  call.gt
ORDER BY
  cnt DESC
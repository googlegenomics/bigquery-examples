# Count the number of calls per sample.
SELECT
  sample_id,
  COUNT(1) AS cnt
FROM
  [google.com:biggene:pgp.cgi_variants]
GROUP BY
  1
ORDER BY
  2 DESC

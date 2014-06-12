# Count the number of calls per sample.
SELECT
  sample_id,
  COUNT(1) AS cnt
FROM
  [pgp.calls]
GROUP BY
  1
ORDER BY
  2 DESC

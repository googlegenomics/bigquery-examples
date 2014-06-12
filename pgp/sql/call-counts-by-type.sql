# Count calls by type.
SELECT
  varType,
  COUNT(1) AS cnt
FROM
  [pgp.calls]
GROUP BY
  1
ORDER BY
  2 DESC

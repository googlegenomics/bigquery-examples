# Find variants on chromosome 17 that reside on the same start with the same reference base
SELECT
  reference_name,
  start,
  reference_bases,
  COUNT(start) AS num_alternates
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
GROUP BY
  reference_name,
  start,
  reference_bases
HAVING
  num_alternates > 1
ORDER BY
  reference_name,
  start,
  reference_bases
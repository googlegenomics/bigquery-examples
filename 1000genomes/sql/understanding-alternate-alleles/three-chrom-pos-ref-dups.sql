# Get three particular start on chromosome 17 that have alternate variants.
SELECT
  reference_name,
  start,
  reference_bases,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  vt,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND (start = 48515942
    OR start = 48570613
    OR start = 48659342)
ORDER BY
  start,
  reference_bases,
  alt

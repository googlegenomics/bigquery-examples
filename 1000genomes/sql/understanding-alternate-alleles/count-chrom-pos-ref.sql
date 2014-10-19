# Count number of alternate variants on chromosome 17 for the same start and
# reference base
SELECT
  num_alternates,
  COUNT(num_alternates) AS num_records
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    COUNT(start) AS num_alternates,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
  GROUP BY
    reference_name,
    start,
    reference_bases)
GROUP BY
  num_alternates

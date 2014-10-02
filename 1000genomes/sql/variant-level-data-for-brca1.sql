# Get variant level metadata for variants within BRCA1.
SELECT
  reference_name,
  start,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
  AND 41277499

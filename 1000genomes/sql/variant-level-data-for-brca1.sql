# Get variant level metadata for variants within BRCA1.
SELECT
  contig,
  position,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
      AND 41277500;

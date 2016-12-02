-- Retrieve variant-level information for BRCA1 variants.
SELECT
  reference_name,
  start,
  `end`,
  reference_bases,
  ARRAY_TO_STRING(v.alternate_bases, ',') AS alts,
  quality,
  ARRAY_TO_STRING(v.filter, ',') AS filter,
  ARRAY_TO_STRING(v.names, ',') AS names,
  vt,
  ARRAY_LENGTH(v.call) AS num_samples
FROM
  `genomics-public-data.1000_genomes.variants` v
WHERE
  reference_name IN ('17', 'chr17')
  AND start BETWEEN 41196311 AND 41277499 # per GRCh37
ORDER BY
  start,
  alts

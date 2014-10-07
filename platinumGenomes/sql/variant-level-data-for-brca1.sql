# Retrieve variant-level information for Platinum Genomes BRCA1 variants.
SELECT
  reference_name,
  start,
  END,
  reference_bases,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alternate_bases,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filter,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  GROUP_CONCAT(STRING(AC)) WITHIN RECORD AS AC,
  AF,
  AN,
  BLOCKAVG_min30p3a,
  BaseQRankSum,
  DP,
  DS,
  Dels,
  FS,
  HRun,
  HaplotypeScore,
  MQ,
  MQ0,
  MQRankSum,
  QD,
  ReadPosRankSum,
  SB,
  VQSLOD,
  culprit,
  variants.set
FROM
  [genomics-public-data:platinum_genomes.variants] AS variants
WHERE
  reference_name = 'chr17'
  AND start BETWEEN 41196311
  AND 41277499
HAVING
  alternate_bases IS NOT NULL
ORDER BY
  start,
  alternate_bases

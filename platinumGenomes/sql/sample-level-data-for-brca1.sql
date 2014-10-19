# Retrieve sample-level information for Platinum Genomes BRCA1 variants.
SELECT
  reference_name,
  start,
  END,
  reference_bases,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alternate_bases,
  call.call_set_name,
  GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
  call.phaseset,
  call.genotype_likelihood,
  GROUP_CONCAT(STRING(call.AD)) WITHIN call AS AD,
  call.DP,
  GROUP_CONCAT(call.FILTER) WITHIN call AS FILTER,
  call.GQ,
  call.GQX,
  call.MQ,
  GROUP_CONCAT(STRING(call.PL)) WITHIN call AS PL,
  call.QUAL,
  call.VF
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
  alternate_bases,
  call.call_set_name

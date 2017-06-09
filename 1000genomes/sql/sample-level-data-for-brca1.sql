#standardSQL
--
-- Retrieve sample-level information for BRCA1 variants.
--
SELECT
  reference_name,
  start,
  `end`,
  reference_bases,
  ARRAY_TO_STRING(v.alternate_bases, ',') AS alts,
  quality,
  ARRAY_TO_STRING(v.filter, ',') AS filters,
  vt,
  ARRAY_TO_STRING(v.names, ',') AS names,
  call.call_set_name,
  call.phaseset,
  (SELECT STRING_AGG(CAST(gt AS STRING)) from UNNEST(call.genotype) gt) AS genotype,
  call.ds,
  (SELECT STRING_AGG(CAST(lh AS STRING)) from UNNEST(call.genotype_likelihood) lh) AS likelihoods
FROM
  `genomics-public-data.1000_genomes.variants` v, v.call call
WHERE
  reference_name IN ('17', 'chr17')
  AND start BETWEEN 41196311 AND 41277499 # per GRCh37
  AND call_set_name = 'HG00100'
ORDER BY
  start,
  alts

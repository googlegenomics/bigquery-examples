# Get sample level data for variants within BRCA1.
SELECT
  reference_name,
  start,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
  call.call_set_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1,
    call.genotype) WITHIN call AS first_allele,
  NTH(2,
    call.genotype) WITHIN call AS second_allele,
  call.ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
      AND 41277499
HAVING
  sample_id = 'HG00100'
ORDER BY
  start

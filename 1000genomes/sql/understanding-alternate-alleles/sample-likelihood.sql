# Get data sufficient to make a judgment upon this particular sample's call.
SELECT
  reference_name,
  start,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  avgpost,
  rsq
  vt,
  call.call_set_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1, call.genotype) WITHIN call AS first_allele,
  NTH(2, call.genotype) WITHIN call AS second_allele,
  call.ds AS ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start = 48515942
HAVING
  sample_id = 'HG00100'
ORDER BY
  alt

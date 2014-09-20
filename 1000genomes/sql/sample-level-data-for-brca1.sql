# Get sample level data for variants within BRCA1.
SELECT
  contig_name,
  start_pos,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
  call.callset_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1,
    call.genotype) WITHIN call AS first_allele,
  NTH(2,
    call.genotype) WITHIN call AS second_allele,
  call.ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND start_pos BETWEEN 41196312
      AND 41277500
HAVING
  sample_id = 'HG00100'

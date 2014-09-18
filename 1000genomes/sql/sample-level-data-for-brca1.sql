# Get sample level data for variants within BRCA1.
SELECT
  contig,
  position,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
  call.callset_name AS sample_id,
  call.ploidy AS ploidy,
  call.phased AS phased,
  call.first_allele AS first_allele,
  call.second_allele AS second_allele,
  call.ds,
  GROUP_CONCAT(STRING(call.gl)) WITHIN call AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
      AND 41277500
HAVING
  sample_id = 'HG00100';
# Get data sufficient to make a judgment upon this particular sample's call.
SELECT
  contig_name,
  position,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  avgpost,
  rsq
  vt,
  call.callset_name AS sample_id,
  call.ploidy AS ploidy,
  call.phased AS phased,
  call.first_allele AS allele1,
  call.second_allele AS allele2,
  call.ds AS ds,
  GROUP_CONCAT(STRING(call.gl)) WITHIN call AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND position = 48515943
HAVING
  sample_id = 'HG00100';
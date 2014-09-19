# Get data sufficient to make a judgment upon this particular sample's call.
SELECT
  contig_name,
  start_pos,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
# TODO: uncomment these when the fields are restored to the table
#  quality,
#  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  avgpost,
  rsq
  vt,
  call.callset_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1, call.genotype) WITHIN call AS allele1,
  NTH(2, call.genotype) WITHIN call AS allele2,
  call.ds AS ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND start_pos = 48515943
HAVING
  sample_id = 'HG00100'
ORDER BY
  alt

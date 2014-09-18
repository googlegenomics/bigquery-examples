# Get data sufficient to make a judgment upon this particular sample's genotype.
SELECT
  contig,
  position,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  avgpost,
  rsq
  vt,
  genotype.sample_id AS sample_id,
  genotype.ploidy AS ploidy,
  genotype.phased AS phased,
  genotype.first_allele AS allele1,
  genotype.second_allele AS allele2,
  genotype.ds AS ds,
  GROUP_CONCAT(STRING(genotype.gl)) WITHIN genotype AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position = 48515943
HAVING
  sample_id = 'HG00100';
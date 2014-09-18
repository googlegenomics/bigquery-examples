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
  genotype.sample_id AS sample_id,
  genotype.ploidy AS ploidy,
  genotype.phased AS phased,
  genotype.first_allele AS first_allele,
  genotype.second_allele AS second_allele,
  genotype.ds,
  GROUP_CONCAT(STRING(genotype.gl)) WITHIN genotype AS likelihoods,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
      AND 41277500
HAVING
  sample_id = 'HG00100';
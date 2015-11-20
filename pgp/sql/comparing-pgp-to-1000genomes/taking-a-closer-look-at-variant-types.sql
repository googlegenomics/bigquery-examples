# Inner SELECT filters just the records in which we are interested.
# Outer SELECT performs our analysis, in this case just a count of the genotypes
# at a particular position in chromosome 3.
SELECT
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  genotype,
  COUNT(genotype) AS number_of_individuals,
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alternate_bases,
    call.callset_name,
    GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
  FROM
    [google.com:biggene:pgp_20150205.genome_calls]
  WHERE
    reference_name = 'chr3'
    AND start = 65440409)
GROUP BY
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  genotype
ORDER BY
  alternate_bases,
  number_of_individuals DESC

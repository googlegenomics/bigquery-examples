# Count the number of genotypes for all individuals in the dataset.
SELECT
  genotype,
  COUNT(genotype) AS cnt,
FROM (
  SELECT
    GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
  FROM
    [google.com:biggene:pgp_20150205.genome_calls])
GROUP BY
  genotype
ORDER BY
  cnt DESC

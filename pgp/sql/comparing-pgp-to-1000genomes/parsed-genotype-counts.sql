# Count the number of sample genotypes, parsed into components.
SELECT
  first_allele,
  phased,
  second_allele,
  dataset,
  cnt
FROM (
  SELECT
    genotype.first_allele AS first_allele,
    genotype.phased AS phased,
    genotype.second_allele AS second_allele,
    COUNT(1) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    first_allele,
    phased,
    second_allele,
    dataset),
  (
  SELECT
    IF(LENGTH(first_allele) = 0
      OR first_allele = ".",
      -1,
      INTEGER(first_allele)) AS first_allele,
    IF(phased = "|",
      TRUE,
      FALSE) AS phased,
    IF(LENGTH(second_allele) = 0
      OR second_allele = ".",
      -1,
      INTEGER(second_allele)) AS second_allele,
    COUNT(1) AS cnt,
    'PGP' AS dataset
  FROM (
    SELECT
      SUBSTR(call.gt,
        1,
        1) AS first_allele,
      SUBSTR(call.gt,
        2,
        1) AS phased,
      SUBSTR(call.gt,
        3,
        1) AS second_allele,
    FROM
      [google.com:biggene:pgp.variants])
  GROUP BY
    first_allele,
    phased,
    second_allele,
    dataset)

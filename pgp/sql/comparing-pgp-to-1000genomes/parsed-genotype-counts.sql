# Count the number of sample genotypes, parsed into components.
SELECT
  first_allele,
  second_allele,
  dataset,
  COUNT(1) AS cnt
FROM (
  SELECT
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  OMIT RECORD IF reference_name IN ('X', 'Y', 'MT')),
  (
  SELECT
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
    'PGP' AS dataset
  FROM
    [google.com:biggene:pgp_20150205.variants_cgi_only]
  OMIT RECORD IF reference_name IN ('chrX', 'chrY', 'chrM'))
GROUP BY
  first_allele,
  second_allele,
  dataset

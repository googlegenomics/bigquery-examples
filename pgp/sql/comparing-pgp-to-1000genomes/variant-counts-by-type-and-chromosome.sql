# Count the number of variants by variant type and chromosome.
SELECT
  reference_name,
  vt,
  cnt,
  dataset
FROM (
  SELECT
    # Normalize the reference_name to match that found in 1,000 Genomes.
    IF(reference_name = 'chrM', 'MT', SUBSTR(reference_name, 4)) AS reference_name,
    IF(ref_len = 1 AND alt_len = 1, "SNP", "INDEL") AS vt,
    COUNT(reference_name) AS cnt,
    'PGP' AS dataset
  FROM (
    SELECT
      reference_name,
      svtype,
      LENGTH(reference_bases) AS ref_len,
      MAX(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
    FROM
      [google.com:biggene:pgp_20150205.genome_calls]
    # The source data was Complete Genomics which includes non-variant segments.
    OMIT RECORD IF EVERY(alternate_bases IS NULL)
      )
  GROUP BY
    reference_name,
    vt
    ),
  (
  SELECT
    reference_name,
    IF(vt IS NULL, "not specified", vt) AS vt,
    COUNT(reference_name) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name,
    vt
    ),
ORDER BY
  reference_name,
  dataset,
  vt

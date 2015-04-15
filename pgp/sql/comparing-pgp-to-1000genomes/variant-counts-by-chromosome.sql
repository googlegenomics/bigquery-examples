# Count the number of variants per chromosome.
SELECT
  reference_name,
  cnt,
  dataset
FROM (
  SELECT
    reference_name,
    COUNT(reference_name) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name
    ),
  (
  SELECT
    # Normalize the reference_name to match that found in 1,000 Genomes.
    IF(reference_name = 'chrM', 'MT', SUBSTR(reference_name, 4)) AS reference_name,
    COUNT(reference_name) AS cnt,
    'PGP' AS dataset
  FROM
    [google.com:biggene:pgp_20150205.variants_cgi_only]
  # The source data was Complete Genomics which includes non-variant segments.
  OMIT RECORD IF EVERY(alternate_bases IS NULL)
  GROUP BY
    reference_name)
ORDER BY
  reference_name,
  dataset

# Sample call counts for the PGP data encoded four different ways.
SELECT
  sample_id,
  num_records,
  INTEGER(0) as num_variants,
  dataset
FROM
  (
  SELECT
    sample_id,
    COUNT(1) AS num_records,
    SUM(reference != '=') AS num_variants,
    'cgi_variants' AS dataset
  FROM
    [google.com:biggene:pgp.cgi_variants]
  # Skip the genomes we were unable to convert to VCF/gVCF
  OMIT RECORD IF 
    sample_id = 'huEDF7DA' OR sample_id = 'hu34D5B9'
  GROUP BY
    sample_id),
  (
  SELECT
    call.callset_name AS sample_id,
    COUNT(1) AS num_records,
#    SUM(alternate_bases IS NOT NULL) AS num_variants,
    'variants' AS dataset
  FROM
    [google.com:biggene:pgp.variants]
  GROUP BY
    sample_id),
  (
  SELECT
    call.callset_name AS sample_id,
    COUNT(1) AS num_records,
#    SUM(alternate_bases IS NOT NULL) AS num_variants,
    'gvcf_variants' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  GROUP BY
    sample_id),
  (
  SELECT
    call.callset_name AS sample_id,
    COUNT(1) AS num_records,
#    SUM(alternate_bases IS NOT NULL) AS num_variants,
    'gvcf_variants_expanded' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded]
  GROUP BY
    sample_id)
ORDER BY
  sample_id,
  dataset

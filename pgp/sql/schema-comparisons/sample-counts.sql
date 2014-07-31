# Sample counts for the PGP data encoded four different ways.
SELECT
  COUNT(DISTINCT sample_id) AS num_samples,
  dataset
FROM
  (
  SELECT
    sample_id,
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
    'variants' AS dataset
  FROM
    [google.com:biggene:pgp.variants]
  GROUP BY
    sample_id),
  (
  SELECT
    call.callset_name AS sample_id,
    'gvcf_variants' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  GROUP BY
    sample_id),
  (
  SELECT
    call.callset_name AS sample_id,
    'gvcf_variants_expanded' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded]
  GROUP BY
    sample_id)
GROUP BY
  dataset

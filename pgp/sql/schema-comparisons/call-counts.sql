# Call counts for the PGP data encoded four different ways.
SELECT
  chromosome,
  num_records,
  num_variants,
  dataset
FROM
  (
  SELECT
    SUBSTR(chromosome,
      4) AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference != '=') AS num_variants,
    'cgi_variants' AS dataset
  FROM
    [google.com:biggene:pgp.cgi_variants]
  # Skip the genomes we were unable to convert to VCF/gVCF
  OMIT RECORD IF 
    sample_id = 'huEDF7DA' OR sample_id = 'hu34D5B9'
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'variants' AS dataset
  FROM
    [google.com:biggene:pgp.variants]
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'gvcf_variants' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'gvcf_variants_expanded' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded2]
  GROUP BY
    chromosome)
ORDER BY
  chromosome,
  dataset

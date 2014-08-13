# Sample call counts for the PGP data encoded several different ways.  
# NOTE: table pgp.variants was left out of this example since its more trouble
# than its worth to parse the GT field into its components. 
SELECT
  sample_id,
  num_records,
  num_variant_alleles,
  dataset
FROM
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(allele1_is_variant + allele2_is_variant)) AS num_variant_alleles,
    'cgi_variants' AS dataset
  FROM (
    SELECT
      sample_id,
      allele1Seq != reference
      AND allele1Seq != '='
      AND allele1Seq != '?' AS allele1_is_variant,
      allele2Seq != reference
      AND allele2Seq != '='
      AND allele2Seq != '?' AS allele2_is_variant,
    FROM
      [google.com:biggene:pgp.cgi_variants]
      # Skip the genomes we were unable to convert to VCF/gVCF
    OMIT
      RECORD IF
      sample_id = 'huEDF7DA'
      OR sample_id = 'hu34D5B9')
  GROUP BY
    sample_id),
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(num_variant_alleles)) AS num_variant_alleles,
    'gvcf_variants' AS dataset
  FROM (
    SELECT
      call.callset_name AS sample_id,
      SUM(call.genotype > 0) WITHIN call AS num_variant_alleles,
    FROM
      [google.com:biggene:pgp.gvcf_variants])
  GROUP BY
    sample_id),
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(num_variant_alleles)) AS num_variant_alleles,
    'gvcf_variants_expanded' AS dataset
  FROM
    (
    SELECT
      call.callset_name AS sample_id,
      SUM(call.genotype > 0) WITHIN call AS num_variant_alleles,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants_expanded2])
  GROUP BY
    sample_id)
ORDER BY
  sample_id,
  dataset

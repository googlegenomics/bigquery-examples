# PGP vs. 1,000 Genomes allelic frequency comparison for BRCA1 variants.
SELECT
  contig_name,
  pgp.reference_bases AS reference_bases,
  start_pos,
  allele,
  pgp_freq,
  af,
  eur_af,
  afr_af,
  asn_af,
  amr_af
FROM (
    FLATTEN((
      SELECT
        reference_name,
        start,
        reference_bases,
        alternate_bases,
        AF,
        AFR_AF,
        AMR_AF,
        ASN_AF,
        EUR_AF
      FROM
        [genomics-public-data:1000_genomes.variants]),
      alternate_bases)) AS kg
JOIN
  EACH (
  SELECT
    contig_name,
    reference_bases,
    start_pos,
    allele,
    freq AS pgp_freq
  FROM
    [google.com:biggene:pgp_analysis_results.gvcf_variants_allelic_frequency]
    ) AS pgp
ON
  pgp.contig_name = kg.reference_name
  AND pgp.start_pos = kg.start
  AND pgp.reference_bases = kg.reference_bases
  AND pgp.allele = kg.alternate_bases
WHERE
  kg.reference_name = '17'
  AND kg.start BETWEEN 41196312
  AND 41277500

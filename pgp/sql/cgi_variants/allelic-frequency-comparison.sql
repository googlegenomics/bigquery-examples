# PGP vs. 1,000 Genomes allelic frequency comparison for BRCA1 variants.
SELECT
  chromosome,
  reference,
  locusBegin,
  locusEnd,
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
    chromosome,
    REGEXP_EXTRACT(chromosome,
      r'chr(\d+)') AS contig,
    reference,
    locusBegin + 1 AS position,
    locusBegin,
    locusEnd,
    allele,
    freq AS pgp_freq
  FROM
    [google.com:biggene:pgp_analysis_results.cgi_variants_allelic_frequency]
    ) AS pgp
ON
  pgp.contig = kg.reference_name
  AND pgp.position = kg.start
  AND pgp.reference = kg.reference_bases
  AND pgp.allele = kg.alternate_bases
WHERE
  kg.reference_name = '17'
  AND kg.start BETWEEN 41196312
  AND 41277500

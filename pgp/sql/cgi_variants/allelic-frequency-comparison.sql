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
FROM
  [google.com:biggene:1000genomes.phase1_variants] AS kg
JOIN EACH (
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
  pgp.contig = kg.contig
  AND pgp.position = kg.position
  AND pgp.reference = kg.reference_bases
  AND pgp.allele = kg.alternate_bases_str
WHERE
  kg.contig = '17'
  AND kg.position BETWEEN 41196312
  AND 41277500

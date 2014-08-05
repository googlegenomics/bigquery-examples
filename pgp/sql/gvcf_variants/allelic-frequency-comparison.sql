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
FROM
  [google.com:biggene:1000genomes.variants1kG] AS kg
JOIN EACH (
  SELECT
    contig_name,
    reference_bases,
    start_pos,
    allele,
    freq AS pgp_freq
  FROM
# pgp_analysis_results.gvcf_variants_allelic_frequency
    [google.com:biggene:test.gvcf_allelic_frequency]
    ) AS pgp
ON
  pgp.contig_name = kg.contig
  AND pgp.start_pos = kg.position
  AND pgp.reference_bases = kg.reference_bases
  AND pgp.allele = kg.alternate_bases_str
WHERE
  kg.contig = '17'
  AND kg.position BETWEEN 41196312
  AND 41277500

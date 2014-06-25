# PGP vs. 1,000 Genomes allelic frequency comparison
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
  [google.com:biggene:1000genomes.variants1kG] AS kg
JOIN (
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
    [google.com:biggene:pgp.brca1_freq]
    ) AS pgp
ON
  pgp.contig = kg.contig
  AND pgp.position = kg.position
  AND pgp.reference = kg.reference_bases
  AND pgp.allele = kg.alternate_bases_str
WHERE
  kg.contig = '17'
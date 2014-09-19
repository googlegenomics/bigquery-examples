# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset further classified by ethnicity from the phenotypic data
# and also includes the pre-computed value from the dataset.
SELECT
  contig_name,
  start_pos,
  super_population,
  reference_bases,
  alternate_bases,
  SUM(ref_count)+SUM(alt_count) AS num_sample_alleles,
  SUM(ref_count) AS sample_allele_ref_cnt,
  SUM(alt_count) AS sample_allele_alt_cnt,
  SUM(ref_count)/(SUM(ref_count)+SUM(alt_count)) AS ref_freq,
  SUM(alt_count)/(SUM(ref_count)+SUM(alt_count)) AS alt_freq,
  alt_freq_from_1KG
FROM (
  SELECT
    contig_name,
    start_pos,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    SUM(IF(0 = allele1,
        1,
        0) + IF(0 = allele2,
        1,
        0)) AS ref_count,
    SUM(IF(alt = allele1,
        1,
        0) + IF(alt = allele2,
        1,
        0)) AS alt_count,
    alt_freq_from_1KG
  FROM (
    SELECT
      g.contig_name AS contig_name,
      g.start_pos AS start_pos,
      p.super_population AS super_population,
      g.reference_bases AS reference_bases,
      g.alternate_bases AS alternate_bases,
      POSITION(g.alternate_bases) AS alt,
      allele1,
      allele2,
      CASE
      WHEN p.super_population =  'ASN'
      THEN  g.asn_af
      WHEN p.super_population=  'EUR'
      THEN g.eur_af
      WHEN p.super_population = 'AFR'
      THEN g.afr_af
      WHEN p.super_population = 'AMR'
      THEN  g.amr_af
      END AS alt_freq_from_1KG
    FROM
      FLATTEN((
        SELECT
          contig_name,
          start_pos,
          reference_bases,
          alternate_bases,
          afr_af,
          amr_af,
          asn_af,
          eur_af,
          call.callset_name,
          NTH(1,
            call.genotype) WITHIN call AS allele1,
          NTH(2,
            call.genotype) WITHIN call AS allele2,
        FROM
          [google.com:biggene:1000genomes.phase1_variants]
        WHERE
          contig_name = '17'
          AND start_pos BETWEEN 41196312
          AND 41277500
          AND vt='SNP'
          ),
        call) AS g
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      g.call.callset_name = p.sample
      )
  GROUP BY
    contig_name,
    start_pos,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    alt_freq_from_1KG)
GROUP BY
  contig_name,
  start_pos,
  super_population,
  reference_bases,
  alternate_bases,
  alt_freq_from_1KG
ORDER BY
  contig_name,
  start_pos,
  super_population

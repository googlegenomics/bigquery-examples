# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset further classified by ethnicity from the phenotypic data 
# and also includes the pre-computed value from the dataset.
SELECT
  contig,
  position,
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
    contig,
    position,
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
      g.contig AS contig,
      g.position AS position,
      p.super_population AS super_population,
      g.reference_bases AS reference_bases,
      g.alternate_bases AS alternate_bases,
      POSITION(g.alternate_bases) AS alt,
      g.genotype.first_allele AS allele1,
      g.genotype.second_allele AS allele2,
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
      FLATTEN([google.com:biggene:1000genomes.phase1_variants],
        genotype) AS g
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      g.genotype.sample_id = p.sample
    WHERE
      g.contig = '17'
      AND g.position BETWEEN 41196312
      AND 41277500
      AND g.vt='SNP'
      )
  GROUP BY
    contig,
    position,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    alt_freq_from_1KG)
GROUP BY
  contig,
  position,
  super_population,
  reference_bases,
  alternate_bases,
  alt_freq_from_1KG
ORDER BY
  contig,
  position,
  super_population;

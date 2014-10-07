# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset further classified by ethnicity from the phenotypic data
# and also includes the pre-computed value from the dataset.
SELECT
  reference_name,
  start,
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
    reference_name,
    start,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    SUM(IF(0 = first_allele,
        1,
        0) + IF(0 = second_allele,
        1,
        0)) AS ref_count,
    SUM(IF(alt = first_allele,
        1,
        0) + IF(alt = second_allele,
        1,
        0)) AS alt_count,
    alt_freq_from_1KG
  FROM (
    SELECT
      g.reference_name AS reference_name,
      g.start AS start,
      p.super_population AS super_population,
      g.reference_bases AS reference_bases,
      g.alternate_bases AS alternate_bases,
      POSITION(g.alternate_bases) AS alt,
      first_allele,
      second_allele,
      CASE
      WHEN p.super_population =  'EAS'
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
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          afr_af,
          amr_af,
          asn_af,
          eur_af,
          call.call_set_name,
          NTH(1,
            call.genotype) WITHIN call AS first_allele,
          NTH(2,
            call.genotype) WITHIN call AS second_allele,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '17'
          AND start BETWEEN 41196311
          AND 41277499
          AND vt='SNP'
          ),
        call) AS g
    JOIN
      [genomics-public-data:1000_genomes.sample_info] p
    ON
      g.call.call_set_name = p.sample
      )
  GROUP BY
    reference_name,
    start,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    alt_freq_from_1KG)
GROUP BY
  reference_name,
  start,
  super_population,
  reference_bases,
  alternate_bases,
  alt_freq_from_1KG
ORDER BY
  reference_name,
  start,
  super_population

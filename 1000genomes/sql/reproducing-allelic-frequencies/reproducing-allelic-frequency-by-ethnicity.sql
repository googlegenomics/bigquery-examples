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
    SUM(INTEGER(0 = call.genotype)) WITHIN RECORD AS ref_count,
    SUM(INTEGER(alt = call.genotype)) WITHIN RECORD AS alt_count,
    CASE
    WHEN super_population =  'EAS'
    THEN  asn_af
    WHEN super_population=  'EUR'
    THEN eur_af
    WHEN super_population = 'AFR'
    THEN afr_af
    WHEN super_population = 'AMR'
    THEN amr_af
    END AS alt_freq_from_1KG
  FROM
    FLATTEN(FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          POSITION(alternate_bases) AS alt,
          call.call_set_name,
          call.genotype,
          afr_af,
          amr_af,
          asn_af,
          eur_af,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '17'
          AND start BETWEEN 41196311
          AND 41277499
          AND vt='SNP'
          ),
        call),
      alt) AS g
  JOIN
    [genomics-public-data:1000_genomes.sample_info] p
  ON
    g.call.call_set_name = p.sample)
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

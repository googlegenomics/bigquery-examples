# The following query computes the allelic frequency for BRCA1 variants in the 
# 1,000 Genomes dataset further classified by gender from the phenotypic data.
SELECT
  reference_name,
  start,
  gender,
  reference_bases,
  alternate_bases
  alt,
  SUM(ref_count)+SUM(alt_count) AS num_sample_alleles,
  SUM(ref_count) AS ref_cnt,
  SUM(alt_count) AS alt_cnt,
  SUM(ref_count)/(SUM(ref_count)+SUM(alt_count)) AS ref_freq,
  SUM(alt_count)/(SUM(ref_count)+SUM(alt_count)) AS alt_freq,
FROM (
  SELECT
    reference_name,
    start,
    gender,
    reference_bases,
    alternate_bases,
    alt,
    SUM(INTEGER(0 = call.genotype)) WITHIN RECORD AS ref_count,
    SUM(INTEGER(alt = call.genotype)) WITHIN RECORD AS alt_count
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
  gender,
  reference_bases,
  alternate_bases,
  alt
ORDER BY
  reference_name,
  start,
  gender,
  reference_bases,
  alt,
  alternate_bases

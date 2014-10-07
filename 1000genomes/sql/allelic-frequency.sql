# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset.
SELECT
  reference_name,
  start,
  reference_bases,
  alternate_bases,
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
        0)) AS alt_count
  FROM (
    SELECT
      reference_name,
      start,
      reference_bases,
      alternate_bases,
      POSITION(alternate_bases) AS alt,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          call.genotype
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '17'
          AND start BETWEEN 41196311
          AND 41277499
          AND vt='SNP'),
        call))
  GROUP BY
    reference_name,
    start,
    reference_bases,
    alternate_bases,
    alt)
GROUP BY
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  alt
ORDER BY
  reference_name,
  start,
  reference_bases,
  alt,
  alternate_bases

# The following query computes the allelic frequency for BRCA1 variants in the 
# 1,000 Genomes dataset.
SELECT
  contig_name,
  position,
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
    contig_name,
    position,
    reference_bases,
    alternate_bases,
    alt,
    SUM(IF(0 = call.first_allele,
        1,
        0) + IF(0 = call.second_allele,
        1,
        0)) AS ref_count,
    SUM(IF(alt = call.first_allele,
        1,
        0) + IF(alt = call.second_allele,
        1,
        0)) AS alt_count
  FROM (
    SELECT
      contig_name,
      position,
      reference_bases,
      alternate_bases,
      POSITION(alternate_bases) AS alt,
      call.first_allele,
      call.second_allele
    FROM
      FLATTEN([google.com:biggene:1000genomes.phase1_variants],
        call)
    WHERE
      contig_name = '17'
      AND position BETWEEN 41196312
      AND 41277500
      AND vt='SNP')
  GROUP BY
    contig_name,
    position,
    reference_bases,
    alternate_bases,
    alt)
GROUP BY
  contig_name,
  position,
  reference_bases,
  alternate_bases,
  alt
ORDER BY
  contig_name,
  position,
  reference_bases,
  alt,
  alternate_bases;

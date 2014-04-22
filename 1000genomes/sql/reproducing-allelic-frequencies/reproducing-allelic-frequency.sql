# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset and also includes the pre-computed value from the dataset.
SELECT
  contig,
  position,
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
    reference_bases,
    alternate_bases,
    alt,
    SUM(IF(0 = genotype.first_allele,
        1,
        0) + IF(0 = genotype.second_allele,
        1,
        0)) AS ref_count,
    SUM(IF(alt = genotype.first_allele,
        1,
        0) + IF(alt = genotype.second_allele,
        1,
        0)) AS alt_count,
    alt_freq_from_1KG
  FROM (
    SELECT
      contig,
      position,
      reference_bases,
      alternate_bases,
      af AS alt_freq_from_1KG,
      POSITION(alternate_bases) AS alt,
      genotype.first_allele,
      genotype.second_allele,
    FROM
      FLATTEN([google.com:biggene:1000genomes.variants1kG],
        genotype)
    WHERE
      contig = '17'
      AND position BETWEEN 41196312
      AND 41277500
      AND vt='SNP')
  GROUP BY
    contig,
    position,
    reference_bases,
    alternate_bases,
    alt,
    alt_freq_from_1KG)
GROUP BY
  contig,
  position,
  reference_bases,
  alternate_bases,
  alt,
  alt_freq_from_1KG
ORDER BY
  contig,
  position;

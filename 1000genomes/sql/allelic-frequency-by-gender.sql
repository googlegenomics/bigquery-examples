# The following query computes the allelic frequency for BRCA1 variants in the 
# 1,000 Genomes dataset further classified by gender from the phenotypic data.
SELECT
  contig,
  position,
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
    contig,
    position,
    gender,
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
        0)) AS alt_count
  FROM (
    SELECT
      g.contig AS contig,
      g.position AS position,
      p.gender AS gender,
      g.reference_bases AS reference_bases,
      g.alternate_bases AS alternate_bases,
      POSITION(g.alternate_bases) AS alt,
      g.genotype.first_allele AS allele1,
      g.genotype.second_allele AS allele2,
    FROM
      FLATTEN([google.com:biggene:1000genomes.variants1kG],
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
    gender,
    reference_bases,
    alternate_bases,
    alt,
  ORDER BY
    contig,
    position,
    gender,
    reference_bases,
    alternate_bases,
    alt)
GROUP BY
  contig,
  position,
  gender,
  reference_bases,
  alternate_bases,
  alt
ORDER BY
  contig,
  position,
  gender,
  reference_bases,
  alt,
  alternate_bases;

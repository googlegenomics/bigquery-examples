# Count the number of samples that have the BRCA1 variant.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  SUM(first_allele > 0
    OR second_allele > 0) AS num_samples_with_variant
  FROM(
    SELECT
      contig_name,
      start_pos,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      [google.com:biggene:1000genomes.phase1_variants]
    WHERE
      contig_name = '17'
      AND start_pos BETWEEN 41196312
      AND 41277500
      AND vt ='SNP'
      )
  GROUP BY
    contig_name,
    start_pos,
    reference_bases,
    alt
ORDER BY
  num_samples_with_variant,
  start_pos

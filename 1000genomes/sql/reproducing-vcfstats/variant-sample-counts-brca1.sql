# Count the number of samples that have the BRCA1 variant.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  SUM(IF(0 < call.first_allele
      OR 0 < call.second_allele,
      1,
      0)) WITHIN RECORD AS num_samples_with_variant
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND start_pos BETWEEN 41196312
  AND 41277500
  AND vt ='SNP'
ORDER BY
  num_samples_with_variant;

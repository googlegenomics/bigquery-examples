# Count the number of samples that have the BRCA1 variant.
SELECT
  contig,
  position,
  reference_bases,
  SUM(IF(0 < genotype.first_allele
      OR 0 < genotype.second_allele,
      1,
      0)) WITHIN RECORD AS num_samples_with_variant
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='SNP'
ORDER BY
  num_samples_with_variant;

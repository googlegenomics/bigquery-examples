# Count SNPs by base pair transition across the dataset
SELECT
  reference_bases,
  alternate_bases AS allele,
  COUNT(alternate_bases) AS num_snps
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  vt ='SNP'
GROUP BY
  reference_bases,
  allele
ORDER BY
  reference_bases,
  allele

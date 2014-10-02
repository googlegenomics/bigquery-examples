# Count SNPs by base pair transition across the dataset
SELECT
  reference_bases,
  alternate_bases AS allele,
  COUNT(alternate_bases) AS num_snps
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  vt ='SNP'
GROUP BY
  reference_bases,
  allele
ORDER BY
  reference_bases,
  allele

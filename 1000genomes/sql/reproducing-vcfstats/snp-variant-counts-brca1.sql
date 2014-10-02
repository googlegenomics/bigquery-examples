# Count SNPs by base pair transition across BRCA1.
SELECT
  reference_bases,
  alternate_bases AS allele,
  COUNT(alternate_bases) AS num_snps
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
  AND 41277499
  AND vt ='SNP'
GROUP BY
  reference_bases,
  allele
ORDER BY
  reference_bases,
  allele
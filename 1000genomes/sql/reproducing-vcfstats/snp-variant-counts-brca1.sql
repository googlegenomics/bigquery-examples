# Count SNPs by base pair transition across BRCA1.
SELECT
  reference_bases,
  alternate_bases AS allele,
  COUNT(alternate_bases) AS num_snps
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='SNP'
GROUP BY
  reference_bases,
  allele
ORDER BY
  reference_bases,
  allele;
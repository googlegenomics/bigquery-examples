# Count the number of variants for each sample across the entirety of the 1,000 
# Genomes dataset by variant type and chromosome.
SELECT
  COUNT(genotype.sample_id) AS variant_count,
  genotype.sample_id,
  contig,
  vt,
FROM 
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  genotype.first_allele > 0
  OR genotype.second_allele > 0
GROUP BY
  genotype.sample_id,
  contig,
  vt
ORDER BY
  variant_count;
# Count the number of variants for each sample across the entirety of the 1,000 
# Genomes dataset by variant type and chromosome.
SELECT
  COUNT(call.callset_name) AS variant_count,
  call.callset_name,
  contig,
  vt,
FROM 
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  call.first_allele > 0
  OR call.second_allele > 0
GROUP BY
  call.callset_name,
  contig,
  vt
ORDER BY
  variant_count;
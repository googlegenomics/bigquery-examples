SELECT
  COUNT(genotype.sample_id) AS variant_count,
  genotype.sample_id,
  contig,
  vt,
FROM 
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  0 != genotype.first_allele
  OR 0 != genotype.second_allele
GROUP BY
  genotype.sample_id,
  contig,
  vt
ORDER BY
  variant_count;
# Sample INDEL counts for BRCA1.
SELECT
  COUNT(genotype.sample_id) AS variant_count,
  genotype.sample_id AS sample_id,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='INDEL'
  AND (0 < genotype.first_allele
    OR 0 < genotype.second_allele)
GROUP BY
  sample_id
ORDER BY
  sample_id;
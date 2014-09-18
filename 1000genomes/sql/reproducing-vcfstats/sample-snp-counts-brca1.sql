# Sample SNP counts for BRCA1.
SELECT
  COUNT(sample_id) AS variant_count,
  sample_id
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    genotype.sample_id AS sample_id
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500
    AND vt ='SNP'
    AND (0 < genotype.first_allele
      OR 0 < genotype.second_allele)
    )
GROUP BY
  sample_id
ORDER BY
  sample_id;

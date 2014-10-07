# Sample INDEL counts for BRCA1.
SELECT
  COUNT(sample_id) AS variant_count,
  sample_id,
FROM (
  SELECT
    call.call_set_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start BETWEEN 41196311
    AND 41277499
    AND vt ='INDEL'
  HAVING
    0 < first_allele
    OR 0 < second_allele)
GROUP BY
  sample_id
ORDER BY
  sample_id

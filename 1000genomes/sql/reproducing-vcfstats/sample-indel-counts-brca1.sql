# Sample INDEL counts for BRCA1.
SELECT
  COUNT(sample_id) AS variant_count,
  sample_id,
FROM (
  SELECT
    call.callset_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
    AND start_pos BETWEEN 41196312
    AND 41277500
    AND vt ='INDEL'
  HAVING
    0 < first_allele
    OR 0 < second_allele)
GROUP BY
  sample_id
ORDER BY
  sample_id

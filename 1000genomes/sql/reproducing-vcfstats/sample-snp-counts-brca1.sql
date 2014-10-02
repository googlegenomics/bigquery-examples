# Sample SNP counts for BRCA1.
SELECT
  COUNT(sample_id) AS variant_count,
  sample_id
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    call.call_set_name AS sample_id
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start BETWEEN 41196311
    AND 41277499
    AND vt ='SNP'
    AND (0 < call.genotype)
    )
GROUP BY
  sample_id
ORDER BY
  sample_id

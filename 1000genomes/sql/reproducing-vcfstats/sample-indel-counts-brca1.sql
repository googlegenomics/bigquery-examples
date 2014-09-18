# Sample INDEL counts for BRCA1.
SELECT
  COUNT(call.callset_name) AS variant_count,
  call.callset_name AS sample_id,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='INDEL'
  AND (0 < call.first_allele
    OR 0 < call.second_allele)
GROUP BY
  sample_id
ORDER BY
  sample_id;
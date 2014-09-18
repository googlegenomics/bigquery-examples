# Find variants on chromosome 17 that reside on the same position with the same reference base
SELECT
  contig_name,
  position,
  reference_bases,
  COUNT(position) AS num_alternates
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
GROUP BY
  contig_name,
  position,
  reference_bases
HAVING
  num_alternates > 1
ORDER BY
  contig_name,
  position,
  reference_bases;
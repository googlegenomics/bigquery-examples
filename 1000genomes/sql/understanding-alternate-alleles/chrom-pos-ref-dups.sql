# Find variants on chromosome 17 that reside on the same start_pos with the same reference base
SELECT
  contig_name,
  start_pos,
  reference_bases,
  COUNT(start_pos) AS num_alternates
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
GROUP BY
  contig_name,
  start_pos,
  reference_bases
HAVING
  num_alternates > 1
ORDER BY
  contig_name,
  start_pos,
  reference_bases
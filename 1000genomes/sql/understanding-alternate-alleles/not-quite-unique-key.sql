# This query demonstrates that some additional field is needed to
# comprise a unique key for the rows in the table.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  alt,
  vt,
  COUNT(1) AS cnt
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
  FROM
    [google.com:biggene:1000genomes.phase1_variants])
  GROUP EACH BY
  contig_name,
  start_pos,
  reference_bases,
  alt,
  vt
HAVING
  cnt > 1
ORDER BY
  contig_name

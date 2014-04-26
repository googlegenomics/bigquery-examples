# This query demonstrates that some additional field is needed to  
# comprise a unique key for the rows in the table.
SELECT
  contig,
  position,
  reference_bases,
  alt,
  vt,
  COUNT(1) AS cnt
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
  FROM
    [google.com:biggene:1000genomes.variants1kG])
  GROUP EACH BY
  contig,
  position,
  reference_bases,
  alt,
  vt
HAVING
  cnt > 1;
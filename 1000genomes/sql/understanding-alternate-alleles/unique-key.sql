# This query demonstrates that an additional field, 'end', is needed to  
# comprise a unique key for the rows in the table.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  alt,
  vt,
  end,
  COUNT(1) AS cnt
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
    end,
  FROM
    [google.com:biggene:1000genomes.phase1_variants])
  GROUP EACH BY
  contig_name,
  start_pos,
  reference_bases,
  alt,
  vt,
  end
HAVING
  cnt > 1
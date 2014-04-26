# This query demonstrates that an additional field, 'end', is needed to  
# comprise a unique key for the rows in the table.
SELECT
  contig,
  position,
  reference_bases,
  alt,
  vt,
  end,
  COUNT(1) AS cnt
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
    end,
  FROM
    [google.com:biggene:1000genomes.variants1kG])
  GROUP EACH BY
  contig,
  position,
  reference_bases,
  alt,
  vt,
  end
HAVING
  cnt > 1;
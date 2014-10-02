# This query demonstrates the minimal set of fields needed to  
# comprise a unique key for the rows in the table.
SELECT
  reference_name,
  start,
  alt,
  end,
  COUNT(1) AS cnt
FROM (
  SELECT
    reference_name,
    start,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    end,
  FROM
    [genomics-public-data:1000_genomes.variants])
  GROUP EACH BY
  reference_name,
  start,
  alt,
  end
HAVING
  cnt > 1
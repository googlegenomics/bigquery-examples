# Which fields constitute a minimum unique key into this data?
SELECT
  contig_name,
  COUNT(1) AS cnt,
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    alt,
    COUNT(1) AS cnt,
  FROM (
    SELECT
      contig_name,
      start_pos,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    FROM
      [google.com:biggene:pgp.variants])
    GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases,
    alt,
  HAVING
    cnt > 1)
GROUP BY
  contig_name;
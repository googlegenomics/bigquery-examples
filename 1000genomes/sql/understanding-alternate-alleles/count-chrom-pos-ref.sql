# Count number of alternate variants on chromosome 17 for the same start_pos and
# reference base
SELECT
  num_alternates,
  COUNT(num_alternates) AS num_records
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    COUNT(start_pos) AS num_alternates,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
  GROUP BY
    contig_name,
    start_pos,
    reference_bases)
GROUP BY
  num_alternates;

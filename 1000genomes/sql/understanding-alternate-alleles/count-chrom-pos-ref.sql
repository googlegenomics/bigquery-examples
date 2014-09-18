# Count number of alternate variants on chromosome 17 for the same position and
# reference base
SELECT
  num_alternates,
  COUNT(num_alternates) AS num_records
FROM (
  SELECT
    contig_name,
    position,
    reference_bases,
    COUNT(position) AS num_alternates,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
  GROUP BY
    contig_name,
    position,
    reference_bases)
GROUP BY
  num_alternates;

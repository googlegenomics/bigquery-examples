# Get three particular start_poss on chromosome 17 that have alternate variants.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  GROUP_CONCAT(id) WITHIN RECORD AS ids,
  vt,
FROM
  [google.com:biggene:1000genomes.phase1_variants]
WHERE
  contig_name = '17'
  AND (start_pos = 48515943
    OR start_pos = 48570614
    OR start_pos = 48659343)
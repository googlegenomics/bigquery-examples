# Count by variant type the number of alternate variants on chromosome 17 for the same 
# start_pos and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [google.com:biggene:1000genomes.phase1_variants] AS variants
JOIN (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    COUNT(start_pos) AS num_alternates,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
  GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases
  HAVING
    num_alternates > 1) AS dups
ON
  variants.contig_name = dups.contig_name
  AND variants.start_pos = dups.start_pos
  AND variants.reference_bases = dups.reference_bases
WHERE
  variants.contig_name = '17'
GROUP EACH BY
  vt;
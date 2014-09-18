# Count by variant type the number of variants on chromosome 17 unique for a 
# position and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [google.com:biggene:1000genomes.phase1_variants] AS variants
JOIN EACH (
  SELECT
    contig_name,
    position,
    reference_bases,
    COUNT(position) AS num_alternates
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig_name = '17'
  GROUP EACH BY
    contig_name,
    position,
    reference_bases
  HAVING
    num_alternates = 1) AS singles
ON
  variants.contig_name = singles.contig_name
  AND variants.position = singles.position
  AND variants.reference_bases = singles.reference_bases
WHERE
  variants.contig_name = '17'
GROUP EACH BY
  vt;
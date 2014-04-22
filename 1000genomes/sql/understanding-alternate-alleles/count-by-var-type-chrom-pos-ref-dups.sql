# Count by variant type the number of alternate variants on chromosome 17 for the same 
# position and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [google.com:biggene:1000genomes.variants1kG] AS variants
JOIN (
  SELECT
    contig,
    position,
    reference_bases,
    COUNT(position) AS num_alternates,
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
  GROUP EACH BY
    contig,
    position,
    reference_bases
  HAVING
    num_alternates > 1) AS dups
ON
  variants.contig = dups.contig
  AND variants.position = dups.position
  AND variants.reference_bases = dups.reference_bases
WHERE
  variants.contig = '17'
GROUP EACH BY
  vt;
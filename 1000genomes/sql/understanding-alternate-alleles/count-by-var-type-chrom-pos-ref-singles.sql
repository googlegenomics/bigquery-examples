# Count by variant type the number of variants on chromosome 17 unique for a
# start and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [genomics-public-data:1000_genomes.variants] AS variants
JOIN EACH (
  SELECT
    reference_name,
    start,
    reference_bases,
    COUNT(start) AS num_alternates
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
  GROUP EACH BY
    reference_name,
    start,
    reference_bases
  HAVING
    num_alternates = 1) AS singles
ON
  variants.reference_name = singles.reference_name
  AND variants.start = singles.start
  AND variants.reference_bases = singles.reference_bases
WHERE
  variants.reference_name = '17'
GROUP EACH BY
  vt
ORDER BY
  vt

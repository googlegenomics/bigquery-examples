# Compute the ratios of variants by type for each chromosome.
SELECT
  contig,
  vt AS variant_type,
  RATIO_TO_REPORT(variant_count)
OVER
  (
  PARTITION BY
    contig
  ORDER BY
    variant_count DESC) ratio_of_variants_of_type_for_contig,
FROM (
  SELECT
    contig,
    vt,
    COUNT(vt) AS variant_count
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    contig,
    vt
  ORDER BY
    contig,
    vt);

# Compute the ratios of variants by type for each chromosome.
SELECT
  contig_name,
  vt AS variant_type,
  RATIO_TO_REPORT(variant_count)
OVER
  (
  PARTITION BY
    contig_name
  ORDER BY
    variant_count DESC) ratio_of_variants_of_type_for_contig_name,
FROM (
  SELECT
    contig_name,
    vt,
    COUNT(vt) AS variant_count
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    contig_name,
    vt
  ORDER BY
    contig_name,
    vt);

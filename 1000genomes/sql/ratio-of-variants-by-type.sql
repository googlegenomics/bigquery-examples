# Compute the ratios of variants by type for each chromosome.
SELECT
  reference_name,
  vt AS variant_type,
  RATIO_TO_REPORT(variant_count)
OVER
  (
  PARTITION BY
    reference_name
  ORDER BY
    variant_count DESC) ratio_of_variants_of_type_for_reference_name,
FROM (
  SELECT
    reference_name,
    vt,
    COUNT(vt) AS variant_count
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name,
    vt
  ORDER BY
    reference_name,
    vt)

# Summarize the variant counts for a particular sample by 10,000 start-wide windows
# in order to identify variant hotspots within a chromosome for a particular sample.
SELECT
  reference_name,
  window,
  window * 10000 AS window_start,
  ((window * 10000) + 9999) AS window_end,
  MIN(start) AS min_variant_start,
  MAX(start) AS max_variant_start,
  sample_id,
  COUNT(sample_id) AS num_variants_in_window,
FROM (
  SELECT
    reference_name,
    start,
    INTEGER(FLOOR(start / 10000)) AS window,
    call.call_set_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    call.call_set_name = 'HG00096'
  HAVING
    first_allele > 0
    OR (second_allele IS NOT NULL
        AND second_allele > 0))
GROUP BY
  reference_name,
  window,
  window_start,
  window_end,
  sample_id
ORDER BY
  num_variants_in_window DESC,
  window

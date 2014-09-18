# Summarize the variant counts by 10,000 position-wide windows in order to identify 
# variant hotspots within a chromosome for all samples.
SELECT
  contig_name,
  window,
  window * 10000 AS window_start,
  ((window * 10000) + 9999) AS window_end,
  MIN(position) AS min_variant_position,
  MAX(position) AS max_variant_position,
  COUNT(sample_id) AS num_variants_in_window,
FROM (
  SELECT
    contig_name,
    position,
    INTEGER(FLOOR(position / 10000)) AS window,
    call.callset_name AS sample_id,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    call.first_allele > 0
      OR call.second_allele > 0)
GROUP BY
  contig_name,
  window,
  window_start,
  window_end,
ORDER BY
  num_variants_in_window DESC,
  window;

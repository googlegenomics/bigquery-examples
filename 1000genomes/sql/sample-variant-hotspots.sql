# Summarize the variant counts for a particular sample by 10,000 start_pos-wide windows 
# in order to identify variant hotspots within a chromosome for a particular sample.
SELECT
  contig_name,
  window,
  window * 10000 AS window_start,
  ((window * 10000) + 9999) AS window_end,
  MIN(start_pos) AS min_variant_start_pos,
  MAX(start_pos) AS max_variant_start_pos,
  sample_id,
  COUNT(sample_id) AS num_variants_in_window,
FROM (
  SELECT
    contig_name,
    start_pos,
    INTEGER(FLOOR(start_pos / 10000)) AS window,
    call.callset_name AS sample_id,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    (call.first_allele > 0
      OR call.second_allele > 0)
    AND call.callset_name = 'HG00096')
GROUP BY
  contig_name,
  window,
  window_start,
  window_end,
  sample_id
ORDER BY
  num_variants_in_window DESC,
  window

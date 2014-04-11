SELECT
  contig,
  window,
  window * 10000 AS window_start,
  ((window * 10000) + 9999) AS window_end,
  MIN(position) AS min_variant_position,
  MAX(position) AS max_variant_position,
  sample_id,
  COUNT(sample_id) AS num_variants_in_window,
FROM (
  SELECT
    contig,
    position,
    INTEGER(FLOOR(position / 10000)) AS window,
    genotype.sample_id AS sample_id,
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    (0 != genotype.first_allele
      OR 0 != genotype.second_allele)
    AND genotype.sample_id = 'HG00096')
GROUP BY
  contig,
  window,
  window_start,
  window_end,
  sample_id
ORDER BY
  num_variants_in_window DESC,
  window;

# What is the meaning of end_pos?
SELECT
  svtype,
  IF(end IS NULL, FALSE, TRUE) AS has_end,
  MIN(end_pos - start_pos) AS min_length_delta,
  MAX(end_pos - start_pos) AS max_length_delta,
  IF((end_pos - start_pos) = 1,
    TRUE,
    FALSE) AS is_ref_allele_one_bp_long,
  COUNT(1) AS cnt,
FROM
  [google.com:biggene:pgp.variants]
GROUP BY
  svtype,
  has_end,
  is_ref_allele_one_bp_long
# What is the meaning of end_pos?
SELECT
  svtype,
  MIN(end_pos - start_pos) AS min_length_delta,
  MAX(end_pos - start_pos) AS max_length_delta,
  IF((end_pos - start_pos) = 1,
    TRUE,
    FALSE) AS is_snp,
  COUNT(1) AS cnt,
FROM
  [google.com:biggene:pgp.variants]
GROUP BY
  svtype,
  is_snp
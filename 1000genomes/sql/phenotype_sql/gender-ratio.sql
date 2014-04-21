# Compute sample count and ratio by gender
SELECT
  gender,
  gender_count,
  RATIO_TO_REPORT(gender_count)
OVER
  (
  ORDER BY
    gender_count) AS gender_ratio
FROM (
  SELECT
    gender,
    COUNT(gender) AS gender_count,
  FROM
    [google.com:biggene:1000genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    gender);
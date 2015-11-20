# Summarize the minimum and maximum number of samples per variant by chromosome.
SELECT
  reference_name,
  MIN(sample_count) AS minimum_sample_count,
  MAX(sample_count) AS maximum_sample_count,
FROM (
  SELECT
    reference_name,
    COUNT(call.call_set_name) WITHIN RECORD AS sample_count
  FROM
    [google.com:biggene:pgp_20150205.genome_calls]
  # The source data was Complete Genomics which includes non-variant segments.
  OMIT RECORD IF EVERY(alternate_bases IS NULL))
GROUP BY
  reference_name
ORDER BY
  reference_name

# Summarize the minimum and maximum number of samples per variant by chromosome.
SELECT
  contig_name,
  MIN(sample_count) AS minimum_sample_count,
  MAX(sample_count) AS maximum_sample_count,
FROM (
  SELECT
    contig_name,
    COUNT(call.callset_name) WITHIN RECORD AS sample_count
  FROM
    [google.com:biggene:pgp.variants]
    )
GROUP BY
  contig_name
ORDER BY
  contig_name
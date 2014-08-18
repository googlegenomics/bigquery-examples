# Confirm that we are correctly expanding reference-matching blocks into our variants.
SELECT
  MAX(num_sample_ids) as max_samples_per_record,
FROM (
  SELECT
    COUNT(call.callset_name) WITHIN RECORD AS num_sample_ids,
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded2]
    )

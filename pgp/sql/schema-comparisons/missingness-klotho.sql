# Missingness rate for Klotho variant rs9536314 in the "amazing
# intelligence of PGP participants" data story.
SELECT
  COUNT(sample_id) AS num_samples_called_for_position,
  SUM(called_count) AS num_alleles_called_for_position,
  1 - (SUM(called_count)/(172*2)) AS missingness_rate
FROM (
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    call.callset_name AS sample_id,
    GROUP_CONCAT(STRING(call.genotype),
      '/') WITHIN call AS genotype,
    SUM(call.genotype >= 0) WITHIN RECORD as called_count,
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  WHERE
    contig_name = '13'
    AND start_pos <= 33628138
    AND (end_pos = 33628139
      OR END >= 33628139)
    )

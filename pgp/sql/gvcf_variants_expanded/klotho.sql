# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story, specifically joining two 
# tables to compare the different encodings.
SELECT
  contig_name,
  start_pos,
  end_pos,
  END,
  ref,
  alt,
  sample_id,
  genotype
FROM
  FLATTEN(
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    reference_bases AS ref,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    call.callset_name AS sample_id,
    GROUP_CONCAT(STRING(call.genotype),
      '/') WITHIN call AS genotype,
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded2]
  WHERE
    contig_name = '13'
    AND start_pos == 33628138
    , call)
ORDER BY
  sample_id

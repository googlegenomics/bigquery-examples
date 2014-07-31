# Missingness rate for variants within BRCA1.
SELECT
  vars.contig_name AS contig_name,
  vars.start_pos AS start_pos,
  reference_bases,
  variant_called_count,
  SUM(refs.called_count) AS reference_called_count,
  variant_called_count + SUM(refs.called_count) AS num_alleles_called_for_position,
  1 - ((variant_called_count + SUM(refs.called_count))/(172*2)) AS missingness_rate
FROM (
    # _JOIN our variant sample counts with the corresponding reference-matching blocks
  SELECT
    vars.contig_name,
    vars.start_pos,
    refs.start_pos,
    vars.end_pos,
    refs.END,
    reference_bases,
    variant_called_count,
    refs.called_count
  FROM (
      # Constrain the left hand side of the _JOIN to reference-matching blocks
    SELECT
      contig_name,
      start_pos,
      END,
      IF(alternate_bases IS NULL,
        FALSE,
        TRUE) AS is_variant_call,
      SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants]
    WHERE
      contig_name = '17'
    HAVING
      is_variant_call = FALSE) AS refs
  JOIN (
      # Constrain the right hand side of the _JOIN to variants
      # _GROUP our variant sample counts together since a single SNP may be IN more than
      # one row due 1 / 2 genotypes
    SELECT
      contig_name,
      start_pos,
      end_pos,
      reference_bases,
      SUM(called_count) AS variant_called_count,
    FROM (
        # _LIMIT the query to SNPs _ON chromosome 17 WITHIN BRCA1
      SELECT
        contig_name,
        start_pos,
        end_pos,
        reference_bases,
        LENGTH(reference_bases) AS ref_len,
        MIN(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
        IF(alternate_bases IS NULL,
          FALSE,
          TRUE) AS is_variant_call,
        SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
      FROM
        [google.com:biggene:test.pgp_gvcf_variants]
      WHERE
        contig_name = '17'
        AND start_pos BETWEEN 41196312
        AND 41277500
      HAVING
        ref_len = 1
        AND alt_len = 1
        AND is_variant_call)
    GROUP BY
      contig_name,
      start_pos,
      end_pos,
      reference_bases) AS vars
    # The _JOIN criteria IS complicated since we are trying to see if a SNP overlaps an interval
  ON
    vars.contig_name = refs.contig_name
  WHERE
    refs.start_pos <= vars.start_pos
    AND refs.END >= vars.end_pos
    )
GROUP BY
  contig_name,
  start_pos,
  reference_bases,
  variant_called_count

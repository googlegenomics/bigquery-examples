# A missingness query on the PGP gVCF variants
SELECT
  num_variant_samples +
  num_reference_samples AS num_samples,
  num_variant_samples,
  num_reference_samples,
  COUNT(1) AS cnt
FROM (
    # _GROUP our reference sample counts
  SELECT
    vars.contig_name,
    vars.start_pos,
    reference_bases,
    num_variant_samples,
    SUM(refs.num_samples) AS num_reference_samples
  FROM (
      # _JOIN our variant sample counts with the corresponding reference-matching blocks
    SELECT
      vars.contig_name,
      vars.start_pos,
      refs.start_pos,
      vars.end_pos,
      refs.the_end,
      reference_bases,
      num_variant_samples,
      refs.num_samples
    FROM (
        # _Limit the lhs of the _JOIN to reference-matching blocks
      SELECT contig_name, bin, start_pos, the_end, num_samples
      FROM js(
      [google.com:biggene:pgp.gvcf_variants],
      contig_name, alternate_bases, start_pos, END, call.callset_name,
        "[{name: 'contig_name', type: 'string'},
         {name: 'bin', type: 'integer'},
         {name: 'start_pos', type: 'integer'},
         {name: 'the_end', type: 'integer'},
         {name: 'num_samples', type: 'integer'}]",
        "function(r, emit) {
           var binSize = 1000
           if ( typeof r.alternate_bases === 'undefined' || r.alternate_bases.length == 0 ) { 
             var startBin = Math.floor(r.start_pos / binSize);
             var endBin = Math.floor(r.END / binSize);
             for(var bin = startBin; bin <= endBin; bin++) {
             emit({
               contig_name: r.contig_name,
               bin: bin,
               start_pos: r.start_pos,
               the_end: r.END,
               num_samples: r.call.length
             });
             }
           }
         }")) AS refs
    JOIN EACH (
        # _GROUP our variant sample counts together since a single SNP may be
        # IN more thanone row due 1 / 2 genotypes
      SELECT
        contig_name,
        INTEGER(FLOOR(start_pos / 1000)) AS bin,
        start_pos,
        end_pos,
        reference_bases,
        SUM(num_samples) AS num_variant_samples,
      FROM (
          # _LIMIT the query to SNPs
        SELECT
          contig_name,
          start_pos,
          end_pos,
          reference_bases,
          LENGTH(reference_bases) AS ref_len,
          MIN(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
          IF(alternate_bases IS NULL,
            TRUE,
            FALSE) AS is_ref_call,
          COUNT(call.callset_name) WITHIN RECORD AS num_samples,
        FROM
          [google.com:biggene:pgp.gvcf_variants]
        HAVING
          ref_len = 1
          AND alt_len = 1
          AND NOT is_ref_call)
      GROUP EACH BY
        contig_name,
        bin,
        start_pos,
        end_pos,
        reference_bases) AS vars
      # The _JOIN criteria IS complicated since we are trying to see if a SNP
      # overlaps an interval
    ON
      vars.contig_name = refs.contig_name AND vars.bin = refs.bin
    WHERE
      refs.start_pos <= vars.start_pos
      AND refs.the_end >= vars.end_pos
      )
  GROUP EACH BY
    vars.contig_name,
    vars.start_pos,
    reference_bases,
    num_variant_samples
    )
GROUP EACH BY
  num_variant_samples,
  num_reference_samples,
  num_samples
ORDER BY
  num_samples DESC,
  cnt DESC

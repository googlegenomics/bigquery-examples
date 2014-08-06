# Missingness rate summarized per chromosome.  To see it per variant, materialize 
# the large result from the inner query to a table.
#
# Note that the new BigQuery feature of user-defined javascript
# functions is in limited preview.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  contig_name,
  MIN(missingness_rate) AS min_missingness,
  AVG(missingness_rate) AS avg_missingness,
  MAX(missingness_rate) AS max_missingness,
  STDDEV(missingness_rate) AS stddev_missingness,
FROM (
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
      refs.the_end,
      reference_bases,
      variant_called_count,
      refs.called_count
    FROM js(
      # Constrain the left hand side of the _JOIN to reference-matching blocks
      (SELECT
         contig_name,
         start_pos,
         END,
         IF(alternate_bases IS NULL,
           FALSE,
           TRUE) AS is_variant_call,
         SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
       FROM
         [google.com:biggene:test.pgp_gvcf_variants]
       HAVING
         is_variant_call = FALSE),
      contig_name, start_pos, END, called_count,
      # This User-defined function helps us reduce the size of the cross product
      # considered by this JOIN thereby greatly speeding up the query.
      "[{name: 'contig_name', type: 'string'},
        {name: 'start_pos', type: 'integer'},
        {name: 'the_end', type: 'integer'},
        {name: 'bin', type: 'integer'},
        {name: 'called_count', type: 'integer'}]",
       "function(r, emit) {
            var binSize = 5000
            var startBin = Math.floor(r.start_pos / binSize);
            var endBin = Math.floor(r.END / binSize);
            // Since a reference-matching block can span multiple bins, emit
            // a record for each bin.
            for(var bin = startBin; bin <= endBin; bin++) {
              emit({
                contig_name: r.contig_name,
                start_pos: r.start_pos,
                the_end: r.END,
                bin: bin,
                called_count: r.called_count
              });
            }
        }") AS refs
    JOIN EACH (
      # Constrain the right hand side of the _JOIN to variants
      # _GROUP our variant sample counts together since a single SNP may be IN more than
      # one row due 1 / 2 genotypes
      SELECT
        contig_name,
        start_pos,
        end_pos,
        INTEGER(FLOOR(start_pos / 5000)) AS bin,
        reference_bases,
        SUM(called_count) AS variant_called_count,
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
            FALSE,
            TRUE) AS is_variant_call,
          SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
        FROM
          [google.com:biggene:test.pgp_gvcf_variants]
        HAVING
          ref_len = 1
          AND alt_len = 1
          AND is_variant_call)
      GROUP EACH BY
        contig_name,
        start_pos,
        end_pos,
        bin,
        reference_bases) AS vars
    # The _JOIN criteria IS complicated since we are trying to see if a SNP overlaps an interval
    ON
      vars.contig_name = refs.contig_name
      AND vars.bin = refs.bin
    WHERE
      refs.start_pos <= vars.start_pos
      AND refs.the_end >= vars.end_pos
      )
  GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases,
    variant_called_count
    )
GROUP BY
  contig_name
ORDER BY
  contig_name
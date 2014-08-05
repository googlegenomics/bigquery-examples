# Compute allelic frequency for chromosome 1 by counting the number of called
# alleles (reference-calls and variant-calls, but leave out no-calls) that 
# overlap each variant allele for which we previously counted its occurence
# in this dataset.  This returns a large result which should be materialized to 
# a table.
SELECT
  vars.contig_name AS contig_name,
  vars.reference_bases AS reference_bases,
  vars.start_pos AS start_pos,
  vars.alternate_bases AS allele,
  alternate_allele_count,
  num_alleles_called,
  ROUND(alternate_allele_count / num_alleles_called,
    4) AS freq,
FROM (
  SELECT
    vars.contig_name,
    vars.reference_bases,
    vars.start_pos,
    vars.alternate_bases,
    alternate_allele_count,
    SUM(num_alleles_called) AS num_alleles_called,
  FROM (
    # The left hand side of our JOIN is are all the calls, including
    # reference_bases calls and no-calls
    SELECT
        SUM(num_alleles_called) AS num_alleles_called,
        contig_name,
        reference_bases,
        bin,
        start_pos,
        the_end,
      # This User-defined function helps us reduce the size of the cross product
      # considered by this JOIN thereby greatly speeding up the query
      FROM js(
      [google.com:biggene:test.pgp_gvcf_variants],
      contig_name, reference_bases, start_pos, end_pos, END, call.genotype,
      "[{name: 'num_alleles_called', type: 'integer'},
        {name: 'contig_name', type: 'string'},
        {name: 'reference_bases', type: 'string'},
        {name: 'bin', type: 'integer'},
        {name: 'start_pos', type: 'integer'},
        {name: 'the_end', type: 'integer'}]",
       "function(r, emit) {
          if (r.contig_name == '1') { 
            var num_alleles_called = 0;
            for(var c in r.call) {
              for(var g in r.call[c].genotype) {
                if(0 <= r.call[c].genotype[g]) {
                  num_alleles_called++;
                }
              }
            }
            var binSize = 5000
            var startBin = Math.floor(r.start_pos / binSize);
            var theEnd = (r.END === null) ? r.end_pos : r.END;
            var endBin = Math.floor(theEnd / binSize);
            for(var bin = startBin; bin <= endBin; bin++) {
              emit({
                num_alleles_called: num_alleles_called,
                contig_name: r.contig_name,
                reference_bases: r.reference_bases,
                bin: bin,
                start_pos: r.start_pos,
                the_end: theEnd
              });
            }
          }
        }")
        GROUP EACH BY
        contig_name,
        reference_bases,
        bin,
        start_pos,
        the_end
        ) AS all
  JOIN
    EACH 
    # The right hand side of our JOIN are counts of alternate allele values at 
    # a particular locus
    [google.com:biggene:pgp_analysis_results.gvcf_variants_allele_counts] AS vars
  ON
    vars.contig_name = all.contig_name
    AND vars.bin = all.bin
  WHERE
    # Further constrain the JOIN to calls that overlapped the first base pair
    # of this variant
    all.start_pos <= vars.start_pos
    AND all.the_end >= vars.start_pos+1
  GROUP EACH BY
    vars.contig_name,
    vars.reference_bases,
    vars.start_pos,
    vars.alternate_bases,
    alternate_allele_count
    )

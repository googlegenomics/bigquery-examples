# Compute allelic frequency for chromosome 1 by counting the number of called
# alleles (reference-calls and variant-calls, but leave out no-calls) that 
# overlap each variant allele for which we previously counted its occurence
# in this dataset.  This returns a large result which should be materialized to 
# a table.
SELECT
  vars.chromosome AS chromosome,
  vars.reference AS reference,
  vars.locusBegin AS locusBegin,
  vars.locusEnd AS locusEnd,
  vars.allele AS allele,
  alternate_allele_count,
  num_alleles_called,
  ROUND(alternate_allele_count / num_alleles_called,
    4) AS freq,
FROM (
  SELECT
    vars.chromosome,
    vars.reference,
    vars.locusBegin,
    vars.locusEnd,
    vars.allele,
    alternate_allele_count,
    SUM(num_alleles_called) AS num_alleles_called,
  FROM (
    # The left hand side of our JOIN is are all the calls, including
    # reference calls (but not no-calls)
    SELECT
        SUM(num_alleles_called) AS num_alleles_called,
        chromosome,
        reference,
        bin,
        locusBegin,
        locusEnd
      # This User-defined function helps us reduce the size of the cross product
      # considered by this JOIN thereby greatly speeding up the query
      FROM js(
      [google.com:biggene:pgp.cgi_variants],
      chromosome, reference, locusBegin, locusEnd, allele1Seq, allele2Seq,
      "[{name: 'num_alleles_called', type: 'integer'},
        {name: 'chromosome', type: 'string'},
        {name: 'reference', type: 'string'},
        {name: 'bin', type: 'integer'},
        {name: 'locusBegin', type: 'integer'},
        {name: 'locusEnd', type: 'integer'}]",
       "function(r, emit) {
          var num_alleles_called = 0;
          if('?' != r.allele1Seq) { num_alleles_called++; }
          if('?' != r.allele2Seq) { num_alleles_called++; }
          var binSize = 5000
          if (r.chromosome == 'chr1') { 
            var startBin = Math.floor(r.locusBegin / binSize);
            var endBin = Math.floor(r.locusEnd / binSize);
            for(var bin = startBin; bin <= endBin; bin++) {
              emit({
                num_alleles_called: num_alleles_called,
                chromosome: r.chromosome,
                reference: r.reference,
                bin: bin,
                locusBegin: r.locusBegin,
                locusEnd: r.locusEnd,
              });
            }
          }
        }")
        GROUP EACH BY
        chromosome,
        reference,
        bin,
        locusBegin,
        locusEnd
        ) AS all
  JOIN
    EACH 
    # The right hand side of our JOIN are counts of alternate allele values at 
    # a particular locus
    [google.com:biggene:pgp_analysis_results.cgi_variants_allele_counts] AS vars
  ON
    vars.chromosome = all.chromosome
    AND vars.bin = all.bin
  WHERE
    # Further constrain the JOIN to calls that overlapped the first base pair
    # of this variant
    all.locusBegin <= vars.locusBegin
    AND all.locusEnd >= vars.locusBegin+1
  GROUP EACH BY
    vars.chromosome,
    vars.reference,
    vars.locusBegin,
    vars.locusEnd,
    vars.allele,
    alternate_allele_count
    )

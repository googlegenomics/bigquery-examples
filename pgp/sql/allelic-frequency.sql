# The following query computes the allelic frequency for BRCA1 variants in the 
# PGP dataset.  Note that the new BigQuery feature of user-defined javascript
# functions is in limited preview.  The output of this query can be found in
# table [google.com:biggene:pgp.brca1_freq].
SELECT
  vars.chromosome AS chromosome,
  vars.reference AS reference,
  vars.locusBegin AS locusBegin,
  vars.locusEnd AS locusEnd,
  vars.allele AS allele,
  alternate_allele_count,
  num_samples_called,
  ROUND(alternate_allele_count / (2*num_samples_called),
    4) AS freq,
FROM (
  SELECT
    vars.chromosome,
    vars.reference,
    vars.locusBegin,
    vars.locusEnd,
    vars.allele,
    alternate_allele_count,
    SUM(num_samples) AS num_samples_called
  FROM (
    # The left hand side of our JOIN are counts of alternate allele values at 
    # a particular locus
    SELECT
      chromosome,
      reference,
      INTEGER(FLOOR(locusBegin / 10000)) AS bin,
      locusBegin,
      locusEnd,
      allele,
      SUM(cnt) AS alternate_allele_count,
    FROM (
      SELECT
        chromosome,
        reference,
        locusBegin,
        locusEnd,
        allele1Seq AS allele,
        COUNT(1) AS cnt
      FROM
        [deflaux-test-1:pgp.calls]
      WHERE
        chromosome = 'chr17'
        AND locusBegin BETWEEN 41196311
        AND 41277499
        AND (reference != '=' OR reference IS NULL)
        AND allele1Seq != '?'
        AND (reference != allele1Seq OR reference IS NULL)
      GROUP BY
        chromosome,
        reference,
        locusBegin,
        locusEnd,
        allele),
      (
      SELECT
        chromosome,
        reference,
        locusBegin,
        locusEnd,
        allele2Seq AS allele,
        COUNT(1) AS cnt
      FROM
        [deflaux-test-1:pgp.calls]
      WHERE
        chromosome = 'chr17'
        AND locusBegin BETWEEN 41196311
        AND 41277499
        AND (reference != '=' OR reference IS NULL)
        AND allele2Seq != '?'
        AND (reference != allele2Seq OR reference IS NULL)
      GROUP BY
        chromosome,
        reference,
        locusBegin,
        locusEnd,
        allele)
    GROUP BY
      chromosome,
      reference,
      bin,
      locusBegin,
      locusEnd,
      allele) AS vars
  JOIN
    EACH (
    # The right hand side of our JOIN is are all the calls, including
    # reference calls and no-calls
    SELECT
      num_samples,
      chromosome,
      bin,
      locusBegin,
      locusEnd
    FROM (
      SELECT
        COUNT(sample_id) AS num_samples,
        chromosome,
        reference,
        bin,
        locusBegin,
        locusEnd
      # This User-defined function helps us reduce the size of the cross product
      # considered by this JOIN thereby greatly speeding up the query
      FROM js(
      [deflaux-test-1:pgp.calls],
      sample_id, chromosome, reference, locusBegin, locusEnd,
      "[{name: 'sample_id', type: 'string'},
        {name: 'chromosome', type: 'string'},
        {name: 'reference', type: 'string'},
        {name: 'bin', type: 'integer'},
        {name: 'locusBegin', type: 'integer'},
        {name: 'locusEnd', type: 'integer'}]",
       "function(r, emit) {
          var binSize = 10000
          if (r.chromosome == 'chr17') { 
            var startBin = Math.floor(r.locusBegin / binSize);
            var endBin = Math.floor(r.locusEnd / binSize);
            for(var bin = startBin; bin <= endBin; bin++) {
              emit({
                sample_id: r.sample_id,
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
        )) AS all
  ON
    vars.chromosome = all.chromosome
    AND vars.bin = all.bin
  WHERE
    # Further constrain the JOIN to calls that overlapped the first base pair
    # of this variant
    all.locusBegin <= vars.locusBegin
    AND all.locusEnd >= vars.locusBegin+1
  GROUP BY
    vars.chromosome,
    vars.reference,
    vars.locusBegin,
    vars.locusEnd,
    vars.allele,
    alternate_allele_count
    )
ORDER BY
  chromosome,
  locusBegin
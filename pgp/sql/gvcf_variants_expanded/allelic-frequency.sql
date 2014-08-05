# This is busted.  It over counts ref calls due in the GROUP BY operation.  It
# would work if we grouped all of the same variant into the same row prior to
# loading to BigQuery because then we would not need the GROUP BY operation.
SELECT
  contig_name,
  start_pos,
  reference_bases,
  alternate_bases,
  ref_count + alt_count + other_count AS num_sample_alleles,
  alt_count/(ref_count + alt_count + other_count) AS alt_freq,
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    alternate_bases,
    SUM(alt_count) AS alt_count,
    SUM(ref_count) AS ref_count,
    SUM(other_count) AS other_count,
  FROM (
    SELECT contig_name, start_pos, reference_bases, alternate_bases, alt_count, ref_count, other_count
      FROM js(
      [google.com:biggene:test.pgp_gvcf_variants_expanded],
      contig_name, start_pos, reference_bases, alternate_bases, call.genotype,
        "[{name: 'contig_name', type: 'string'},
          {name: 'start_pos', type: 'integer'},
          {name: 'reference_bases', type: 'string'},
          {name: 'alternate_bases', type: 'string'},
          {name: 'alt_count', type: 'integer'},
          {name: 'ref_count', type: 'integer'},
          {name: 'other_count', type: 'integer'}]",
        "function(r, emit) {
           for(var a in r.alternate_bases) {
             var alt_gt = a + 1;
             var ref_count = 0;
             var alt_count = 0;
             var other_count = 0;
             for(var c in r.call) {
               for(var g in r.call[c].genotype) {
                 if(0 > r.call[c].genotype[g]) {
                   // Don't count no-calls
                   continue;
                 } else if (0 == r.call[c].genotype[g]) {
                   ref_count++;
                 } else if (alt_gt == r.call[c].genotype[g]) {
                   alt_count++;
                 } else {
                   other_count++;
                 }
               }
             }
             // Emit one record per alt
             emit({
               contig_name: r.contig_name,
               start_pos: r.start_pos,
               reference_bases: r.reference_bases,
               alternate_bases: r.alternate_bases[a],
               alt_count: alt_count,
               ref_count: ref_count,
               other_count: other_count
             });
           }
         }"))
  GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases,
    alternate_bases)

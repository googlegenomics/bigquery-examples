# Count the occurence of each variant allele across all participants in the
# dataset.  This returns a large result so be sure to materialize it into a
# table for subsequent use. 
#
# Note that the new BigQuery feature of user-defined javascript
# functions is in limited preview.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  contig_name,
  start_pos,
  # This 'bin' can be use in subsequent interval JOINs
  INTEGER(FLOOR(start_pos / 5000)) AS bin,
  reference_bases,
  alternate_bases,
  SUM(alternate_allele_count) AS alternate_allele_count,
FROM (
  SELECT contig_name, start_pos, reference_bases, alternate_bases, alt_count
  FROM js(
    [google.com:biggene:pgp.gvcf_variants],
    contig_name, start_pos, reference_bases, alternate_bases, call.genotype,
      "[{name: 'contig_name', type: 'string'},
        {name: 'start_pos', type: 'integer'},
        {name: 'reference_bases', type: 'string'},
        {name: 'alternate_bases', type: 'string'},
        {name: 'alternate_allele_count', type: 'integer'}]",
      "function(r, emit) {
         for(var a in r.alternate_bases) {
           var alt_gt = a + 1;
           var alt_count = 0;
           for(var c in r.call) {
             for(var g in r.call[c].genotype) {
               if(alt_gt == r.call[c].genotype[g]) {
                 alt_count++;
               }
             }
           }
           // Emit one record per alt
           emit({
             contig_name: r.contig_name,
             start_pos: r.start_pos,
             reference_bases: r.reference_bases,
             alternate_bases: r.alternate_bases[a],
             alternate_allele_count: alt_count
           });
         }
       }"))
GROUP EACH BY
  contig_name,
  start_pos,
  bin,
  reference_bases,
  alternate_bases

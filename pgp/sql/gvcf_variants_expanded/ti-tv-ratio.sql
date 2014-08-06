# Compute the Ti/Tv ratio for each participant in the PGP dataset.  A user-defined
# function is used here since its difficult in SQL to join the genotype array in
# each call with alternate_bases at the variant level.
#
# Note that the new BigQuery feature of user-defined javascript
# functions is in limited preview.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  sample_id,
  transitions,
  transversions,
  transitions/transversions AS titv
FROM (
  SELECT
    sample_id,
    SUM(IF(mutation IN ('A->G',
          'G->A',
          'C->T',
          'T->C'),
        1,
        0)) AS transitions,
    SUM(IF(mutation IN ('A->C',
          'C->A',
          'G->T',
          'T->G',
          'A->T',
          'T->A',
          'C->G',
          'G->C'),
        1,
        0)) AS transversions,
  FROM (
    SELECT sample_id, mutation
      FROM js(
      [google.com:biggene:test.pgp_gvcf_variants_expanded],
      reference_bases, alternate_bases, call.callset_name, call.genotype,
        "[{name: 'sample_id', type: 'string'},
          {name: 'mutation', type: 'string'}]",
        "function(r, emit) {
           var hasSNP = false;
           var isSNP = [false];
           for(var i in r.alternate_bases) {
              if(1 == r.alternate_bases[i].length) {
                isSNP[isSNP.length] = true;
                hasSNP = true;
              }
              else {
                isSNP[isSNP.length] = false;
              }
           }
           if (hasSNP && 1 == r.reference_bases.length) { 
             for(var i in r.call) {
               for(var j in r.call[i].genotype) {
                 if(0 < r.call[i].genotype[j] && isSNP[r.call[i].genotype[j]]) {
                   emit({
                    sample_id: r.call[i].callset_name,
                    mutation: r.reference_bases + '->' + r.alternate_bases[r.call[i].genotype[j] - 1] 
                   });
                 }
               }
             }
           }
         }")
        )
  GROUP BY
    sample_id)
ORDER BY
  titv DESC

# Get sample alleles for some specific variants.  
# TODO(deflaux): update this to a user-defined function to generalize 
# across more than two alternates.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  contig,
  position,
  ids,
  reference_bases,
  sample_id,
  CASE
  WHEN 0 = allele1 THEN reference_bases
  WHEN 1 = allele1 THEN alt1
  WHEN 2 = allele1 THEN alt2 END AS allele1,
  CASE
  WHEN 0 = allele2 THEN reference_bases
  WHEN 1 = allele2 THEN alt1
  WHEN 2 = allele2 THEN alt2 END AS allele2,
FROM(
  SELECT
    contig,
    position,
    GROUP_CONCAT(id) WITHIN RECORD AS ids,
    reference_bases,
    genotype.sample_id AS sample_id,
    NTH(1,
      alternate_bases) WITHIN RECORD AS alt1,
    NTH(2,
      alternate_bases) WITHIN RECORD AS alt2,
    genotype.first_allele AS allele1,
    genotype.second_allele AS allele2
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  WHERE
    contig = '17'
    AND position = 48515943
  HAVING
    sample_id = 'HG00100' OR sample_id = 'HG00101');
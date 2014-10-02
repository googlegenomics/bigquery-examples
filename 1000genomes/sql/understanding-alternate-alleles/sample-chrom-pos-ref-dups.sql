# Get sample alleles for some specific variants.
# TODO(deflaux): update this to a user-defined function to generalize
# across more than two alternates.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  reference_name,
  start,
  alt,
  reference_bases,
  sample_id,
  CASE
  WHEN 0 = first_allele THEN reference_bases
  WHEN 1 = first_allele THEN alt1
  WHEN 2 = first_allele THEN alt2 END AS first_allele,
  CASE
  WHEN 0 = second_allele THEN reference_bases
  WHEN 1 = second_allele THEN alt1
  WHEN 2 = second_allele THEN alt2 END AS second_allele,
FROM(
  SELECT
    reference_name,
    start,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    reference_bases,
    call.call_set_name AS sample_id,
    NTH(1,
      alternate_bases) WITHIN RECORD AS alt1,
    NTH(2,
      alternate_bases) WITHIN RECORD AS alt2,
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start = 48515943
  HAVING
    sample_id = 'HG00100' OR sample_id = 'HG00101')
ORDER BY
  alt,
  sample_id

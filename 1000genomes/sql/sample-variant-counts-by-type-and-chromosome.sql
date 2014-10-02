# Count the number of variants for each sample across the entirety of the 1,000
# Genomes dataset by variant type and chromosome.
SELECT
  reference_name,
  vt,
  sample_id,
  COUNT(sample_id) AS variant_count,
FROM
  (
  SELECT
    reference_name,
    vt,
    call.call_set_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants]
  HAVING
    first_allele > 0
    OR second_allele > 0)
GROUP BY
  sample_id,
  reference_name,
  vt
ORDER BY
  reference_name,
  vt,
  variant_count,
  sample_id

# Count the number of variants for each sample across the entirety of the 1,000
# Genomes dataset by variant type and chromosome.
SELECT
  contig_name,
  vt,
  sample_id,
  COUNT(sample_id) AS variant_count,
FROM
  (
  SELECT
    contig_name,
    vt,
    call.callset_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  HAVING
    first_allele > 0
    OR second_allele > 0)
GROUP BY
  sample_id,
  contig_name,
  vt
ORDER BY
  contig_name,
  vt,
  variant_count,
  sample_id

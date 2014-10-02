# Count the homozygous and heterozygous variants for each sample across the
# entirety of the 1,000 Genomes dataset.
SELECT
  sample_id,
  SUM(IF(0 = first_allele
      AND 0 = second_allele,
      1,
      0)) AS hom_RR_count,
  SUM(IF(first_allele = second_allele
      AND first_allele > 0,
      1,
      0)) AS hom_AA_count,
  SUM(IF((first_allele != second_allele
        OR second_allele IS NULL)
      AND (first_allele > 0
        OR second_allele > 0),
      1,
      0)) AS het_RA_count
FROM (
  SELECT
    reference_name,
    call.call_set_name AS sample_id,
    NTH(1,
      call.genotype) WITHIN call AS first_allele,
    NTH(2,
      call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants])
GROUP BY
  sample_id
ORDER BY
  sample_id

# Count the homozygous and heterozygous variants for each sample across the 
# entirety of the 1,000 Genomes dataset.
SELECT
  call.callset_name AS sample_id,
  SUM(IF(0 = call.first_allele
      AND 0 = call.second_allele,
      1,
      0)) AS hom_RR_count,
  SUM(IF(call.first_allele = call.second_allele
      AND call.first_allele > 0,
      1,
      0)) AS hom_AA_count,
  SUM(IF(call.first_allele != call.second_allele
      AND (call.first_allele > 0
        OR call.second_allele > 0),
      1,
      0)) AS het_RA_count
FROM
  [google.com:biggene:1000genomes.phase1_variants]
GROUP BY
  sample_id
ORDER BY
  sample_id

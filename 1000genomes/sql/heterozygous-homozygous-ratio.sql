# Count the homozygous and heterozygous variants for each sample across the 
# entirety of the 1,000 Genomes dataset.
SELECT
  genotype.sample_id AS sample_id,
  SUM(IF(0 = genotype.first_allele
      AND 0 = genotype.second_allele,
      1,
      0)) AS hom_RR_count,
  SUM(IF(genotype.first_allele = genotype.second_allele
      AND genotype.first_allele > 0,
      1,
      0)) AS hom_AA_count,
  SUM(IF(genotype.first_allele != genotype.second_allele
      AND (genotype.first_allele > 0
        OR genotype.second_allele > 0),
      1,
      0)) AS het_RA_count
FROM
  [google.com:biggene:1000genomes.variants1kG]
GROUP BY
  sample_id
ORDER BY
  sample_id;

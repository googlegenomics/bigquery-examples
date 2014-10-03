# The following query uses the homozygous and heterozygous variant counts within
# chromosome X to help determine whether the gender phenotype values are correct
# for the samples.
SELECT
  sample_id,
  gender,
  reference_name,
  (hom_AA_count + het_RA_count + hom_RR_count) AS all_callable_sites,
  hom_AA_count,
  het_RA_count,
  hom_RR_count,
  (hom_AA_count + het_RA_count) AS all_snvs,
  ROUND((het_RA_count/(hom_AA_count + het_RA_count))*1000)/1000 AS perct_het_alt_in_snvs,
  ROUND((hom_AA_count/(hom_AA_count + het_RA_count))*1000)/1000 AS perct_hom_alt_in_snvs
FROM
  (
  SELECT
    reference_name,
    sample_id,
    SUM(IF(0 = first_allele
        AND 0 = second_allele,
        1,
        0)) AS hom_RR_count,
    SUM(IF(first_allele = second_allele
        AND first_allele > 0,
        1,
        0)) AS hom_AA_count,
    SUM(IF((first_allele != second_allele OR second_allele IS NULL)
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
      [genomics-public-data:1000_genomes.variants]
    WHERE
      reference_name = 'X'
      AND vt = 'SNP'
      AND start NOT BETWEEN 59999
      AND 2699519
      AND start NOT BETWEEN 154931042
      AND 155260559)
  GROUP BY
    sample_id,
    reference_name
    ) AS g
JOIN
  [genomics-public-data:1000_genomes.sample_info] p
ON
  g.sample_id = p.sample
GROUP BY
  sample_id,
  gender,
  reference_name,
  all_callable_sites,
  hom_AA_count,
  het_RA_count,
  hom_RR_count,
  all_snvs,
  perct_het_alt_in_snvs,
  perct_hom_alt_in_snvs
ORDER BY
  perct_het_alt_in_snvs DESC,
  sample_id


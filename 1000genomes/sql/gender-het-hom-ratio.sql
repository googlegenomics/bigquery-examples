# The following query uses the homozygous and heterozygous variant counts within 
# chromosome X to help determine whether the gender phenotype values are correct 
# for the samples.
SELECT
  sample_id,
  gender,
  contig_name,
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
    call.callset_name AS sample_id,
    contig_name,
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
  WHERE
    contig_name = 'X'
    AND vt = 'SNP'
    AND start_pos NOT BETWEEN 60000
    AND 2699520
    AND start_pos NOT BETWEEN 154931043
    AND 155260560
  GROUP BY
    sample_id,
    contig_name
    ) AS g
JOIN
  [google.com:biggene:1000genomes.sample_info] p
ON
  g.sample_id = p.sample
GROUP BY
  sample_id,
  gender,
  contig_name,
  all_callable_sites,
  hom_AA_count,
  het_RA_count,
  hom_RR_count,
  all_snvs,
  perct_het_alt_in_snvs,
  perct_hom_alt_in_snvs
ORDER BY
perct_het_alt_in_snvs desc,
  sample_id

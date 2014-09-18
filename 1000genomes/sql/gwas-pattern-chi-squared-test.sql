# An example of a pattern one might use for GWAS queries upon 1,000
# Genomes variants.  It is specifically examining differences allelic
# frequency for variants upon chromosome 12 between the ASN super
# population versus all other individuals, returning a ranked list of
# variants by decreasing variation between groups.  Note that this
# particular query below is naive in many, many respects and is merely
# meant as an over-simplified example that might help domain experts
# translate their scientifically correct data filtering and
# statistical methods to BigQuery.  Feedback to improve this query is
# most welcome!

# http://www.statisticslectures.com/topics/goodnessoffit/
# http://homes.cs.washington.edu/~suinlee/genome560/lecture7.pdf
# http://bioinformatics.ca/files/Statistics/Statistics_Day2-Module8.pdf
# Chi-squared critical value for df=1, p-value=5*10^-8 is 29.71679
# > qchisq(1 - 5e-08, df=1) 
#   [1] 29.71679

# For example, see alcohol flush reaction at position 112241766 

SELECT
  contig_name,
  position,
  end,
  reference_bases,
  alternate_bases,
  vt,
  case_count,
  control_count,
  allele_count,
  ref_count,
  alt_count,
  case_ref_count,
  case_alt_count,
  control_ref_count,
  control_alt_count,
  ROUND(
    POW(case_ref_count - (ref_count/allele_count)*case_count,
      2)/((ref_count/allele_count)*case_count) +
    POW(control_ref_count - (ref_count/allele_count)*control_count,
      2)/((ref_count/allele_count)*control_count) +
    POW(case_alt_count - (alt_count/allele_count)*case_count,
      2)/((alt_count/allele_count)*case_count) +
    POW(control_alt_count - (alt_count/allele_count)*control_count,
      2)/((alt_count/allele_count)*control_count),
    3)
  AS chi_squared_score
FROM (
  SELECT
    contig_name,
    position,
    end,
    reference_bases,
    alternate_bases,
    vt,
    SUM(ref_count + alt_count) AS allele_count,
    SUM(ref_count) AS ref_count,
    SUM(alt_count) AS alt_count,
    SUM(IF(TRUE = is_case,
        INTEGER(ref_count + alt_count),
        0)) AS case_count,
    SUM(IF(FALSE = is_case,
        INTEGER(ref_count + alt_count),
        0)) AS control_count,
    SUM(IF(TRUE = is_case,
        ref_count,
        0)) AS case_ref_count,
    SUM(IF(TRUE = is_case,
        alt_count,
        0)) AS case_alt_count,
    SUM(IF(FALSE = is_case,
        ref_count,
        0)) AS control_ref_count,
    SUM(IF(FALSE = is_case,
        alt_count,
        0)) AS control_alt_count,
  FROM (
    SELECT
      contig_name,
      position,
      IF('ASN' = super_population,
        TRUE,
        FALSE) AS is_case,
      reference_bases,
      alternate_bases,
      end,
      vt,
      # 1,000 genomes data is bi-allelic so there is only ever a single alt
      (0 = call.first_allele) + (0 = call.second_allele) AS ref_count,
      (1 = call.first_allele) + (1 = call.second_allele) AS alt_count,
    FROM
      FLATTEN([google.com:biggene:1000genomes.phase1_variants],
        call) AS g
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      g.call.callset_name = p.sample
    WHERE
      contig_name = '12'
      # Exclude calls where one or both alleles were not called (-1)
      AND 0 <= call.first_allele AND 0 <= call.second_allele
      )
  GROUP BY
    contig_name,
    position,
    end,
    reference_bases,
    alternate_bases,
    vt)
WHERE
  # For chi-squared, expected counts must be at least 5 for each group
  (ref_count/allele_count)*case_count >= 5.0
  AND (ref_count/allele_count)*control_count >= 5.0
  AND (alt_count/allele_count)*case_count >= 5.0
  AND (alt_count/allele_count)*control_count >= 5.0
HAVING
  # Chi-squared critical value for df=1, p-value=5*10^-8 is 29.71679
  chi_squared_score >= 29.71679
ORDER BY
  chi_squared_score DESC,
  allele_count DESC

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

# http://www.statisticslectures.com/topics/ztestproportions/
# two-proportion z-test
# z-score critical value for p-value=5*10^-8 is +/-5.326724
# > qnorm(1 - 5e-08) 
# [1] 5.326724

# For example, see alcohol flush reaction at position 112241766 

SELECT
  contig,
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
    (case_alt_count/case_count - control_alt_count/control_count)
    /
    SQRT(
      ((((case_alt_count+control_alt_count)/allele_count) * 
        ((case_ref_count+control_ref_count)/allele_count))
       / case_count
      )
      +
      ((((case_alt_count+control_alt_count)/allele_count) *
        ((case_ref_count+control_ref_count)/allele_count))
       / control_count
      )
    )
    ,
    3)
  AS z_score
FROM (
  SELECT
    contig,
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
      contig,
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
      contig = '12'
      # Exclude calls where one or both alleles were not called (-1)
      AND 0 <= call.first_allele AND 0 <= call.second_allele
      )
  GROUP BY
    contig,
    position,
    end,
    reference_bases,
    alternate_bases,
    vt)
HAVING
  z_score >= 5.326724 OR z_score <= -5.326724
ORDER BY
  z_score DESC,
  allele_count DESC

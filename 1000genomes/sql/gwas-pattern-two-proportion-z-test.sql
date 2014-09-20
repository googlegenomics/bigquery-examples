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

# For example, see alcohol flush reaction at start_pos 112241766

SELECT
  contig_name,
  start_pos,
  END,
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
    contig_name,
    start_pos,
    END,
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
      start_pos,
      IF('ASN' = super_population,
        TRUE,
        FALSE) AS is_case,
      reference_bases,
      alternate_bases,
      END,
      vt,
      # 1000 genomes data IS bi-allelic so there IS only ever a single alt
      (0 = first_allele) + (0 = second_allele) AS ref_count,
      (1 = first_allele) + (1 = second_allele) AS alt_count,
    FROM
      FLATTEN((
        SELECT
          contig_name,
          start_pos,
          reference_bases,
          alternate_bases,
          END,
          vt,
          call.callset_name,
          NTH(1,
            call.genotype) WITHIN call AS first_allele,
          NTH(2,
            call.genotype) WITHIN call AS second_allele,
        FROM
          [google.com:biggene:1000genomes.phase1_variants]
        WHERE
          contig_name = '12'
        HAVING
          # Exclude calls _where one _or both alleles were NOT called (-1)
          0 <= first_allele
          AND 0 <= second_allele
          ),
        call) AS g
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      g.call.callset_name = p.sample
      )
  GROUP BY
    contig_name,
    start_pos,
    END,
    reference_bases,
    alternate_bases,
    vt)
HAVING
  z_score >= 5.326724
  OR z_score <= -5.326724
ORDER BY
  z_score DESC,
  allele_count DESC

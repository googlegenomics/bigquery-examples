# An example of a pattern one might use for GWAS queries upon 1,000
# Genomes variants.  It is specifically examining differences allelic
# frequency for variants upon chromosome 12 between the EAS super
# population versus all other individuals, returning a ranked list of
# variants by decreasing variation between groups.  Note that this
# particular query below is naive in many, many respects and is merely
# meant as an over-simplified example that might help domain experts
# translate their scientifically correct data filtering and
# statistical methods to BigQuery.  Feedback to improve this query is
# most welcome!

# http://www.statisticslectures.com/topics/ztestproportions/
# two-proportion z-test
# z-score critical value for p-value=5*10^-8 is +/-5.45131
#
#   > qnorm(1 - ((5e-8)/2), lower.tail=T)
#   [1] 5.45131
#   > qnorm(1 - ((5e-8)/2), lower.tail=F)
#   [1] -5.45131

SELECT
  reference_name,
  start,
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
    reference_name,
    start,
    end,
    reference_bases,
    alternate_bases,
    vt,
    SUM(ref_count + alt_count) AS allele_count,
    SUM(ref_count) AS ref_count,
    SUM(alt_count) AS alt_count,
    SUM(IF(TRUE = is_case, INTEGER(ref_count + alt_count), 0)) AS case_count,
    SUM(IF(FALSE = is_case, INTEGER(ref_count + alt_count), 0)) AS control_count,
    SUM(IF(TRUE = is_case, ref_count, 0)) AS case_ref_count,
    SUM(IF(TRUE = is_case, alt_count, 0)) AS case_alt_count,
    SUM(IF(FALSE = is_case, ref_count, 0)) AS control_ref_count,
    SUM(IF(FALSE = is_case, alt_count, 0)) AS control_alt_count,
  FROM (
    SELECT
      reference_name,
      start,
      ('EAS' = super_population) AS is_case,
      reference_bases,
      alternate_bases,
      END,
      vt,
      # 1000 genomes phase 1 data is bi-allelic so there is only ever a single alt
      SUM(0 = call.genotype) WITHIN RECORD AS ref_count,
      SUM(1 = call.genotype) WITHIN RECORD AS alt_count,
    FROM
      FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          END,
          vt,
          call.call_set_name,
          call.genotype,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '12'
          ),
        call) AS g
    JOIN
      [genomics-public-data:1000_genomes.sample_info] p
    ON
      g.call.call_set_name = p.sample
      )
  GROUP BY
    reference_name,
    start,
    end,
    reference_bases,
    alternate_bases,
    vt)
HAVING
  z_score >= 5.45131
  OR z_score <= -5.45131
ORDER BY
  z_score DESC,
  allele_count DESC

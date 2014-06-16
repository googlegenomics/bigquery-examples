# An example of a pattern one might use for GWAS queries upon 1,000 Genomes
# variants.  Note that this particular query below is naive in _many_ respects
# --> for example in its treatment of no-call variants.  Feedback to improve
# this query is most welcome!

# two-proportion z-test
# alpha = 0.01

# For example, see alcohol flush reaction at position 112241766 

SELECT
  contig,
  position,
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
    contig,
    position,
    END,
    reference_bases,
    alternate_bases,
    vt,
    SUM(TRUE = is_case) AS case_count,
    SUM(FALSE = is_case) AS control_count,
    SUM(1) AS allele_count,
    SUM(ref_count) AS ref_count,
    SUM(alt_count) AS alt_count,
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
      END,
      vt,
      # Ignore no-calls (-1) and 1,000 genomes data bi-allelic
      (0 = genotype.first_allele) + (0 = genotype.second_allele) AS ref_count,
      (1 = genotype.first_allele) + (1 = genotype.second_allele) AS alt_count,
    FROM
      FLATTEN([google.com:biggene:1000genomes.variants1kG],
        genotype) AS g
    JOIN
      [google.com:biggene:1000genomes.sample_info] p
    ON
      g.genotype.sample_id = p.sample
    WHERE
      contig = '12'
      )
  GROUP BY
    contig,
    position,
    END,
    reference_bases,
    alternate_bases,
    vt)
HAVING
  z_score >= 2.33
ORDER BY
  z_score DESC,
  allele_count DESC
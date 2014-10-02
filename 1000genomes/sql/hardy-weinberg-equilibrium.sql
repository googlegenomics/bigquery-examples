# An example of a pattern one might use for Hardy-Weinberg Equilibrium
# queries upon 1,000 Genomes variants.  It is specifically computing
# the Hardy-Weinberg Equilibrium for the variants found in BRCA1 and
# then computing the chi-squared score for the observed versus
# expected counts for the calls.

# http://scienceprimer.com/hardy-weinberg-equilibrium-calculator
# http://www.nfstc.org/pdi/Subject07/pdi_s07_m01_02.htm
# http://www.nfstc.org/pdi/Subject07/pdi_s07_m01_02.p.htm

SELECT
  reference_name,
  start,
  END,
  reference_bases,
  alt,
  vt,
  ROUND(POW(hom_ref_count - expected_hom_ref_count,
      2)/expected_hom_ref_count +
    POW(hom_alt_count - expected_hom_alt_count,
      2)/expected_hom_alt_count +
    POW(het_count - expected_het_count,
      2)/expected_het_count,
    3) AS chi_squared_score,
  total_count,
  hom_ref_count,
  ROUND(expected_hom_ref_count,
    2) AS expected_hom_ref_count,
  het_count,
  ROUND(expected_het_count,
    2) AS expected_het_count,
  hom_alt_count,
  ROUND(expected_hom_alt_count,
    2) AS expected_hom_alt_count,
  ROUND(alt_freq,
    4) AS alt_freq,
  alt_freq_from_1KG,
FROM (
  SELECT
    reference_name,
    start,
    END,
    reference_bases,
    alt,
    vt,
    alt_freq_from_1KG,
    hom_ref_freq + (.5 * het_freq) AS hw_ref_freq,
    1 - (hom_ref_freq + (.5 * het_freq)) AS alt_freq,
    POW(hom_ref_freq + (.5 * het_freq),
      2) * total_count AS expected_hom_ref_count,
    POW(1 - (hom_ref_freq + (.5 * het_freq)),
      2) * total_count AS expected_hom_alt_count,
    2 * (hom_ref_freq + (.5 * het_freq))
    * (1 - (hom_ref_freq + (.5 * het_freq)))
    * total_count AS expected_het_count,
    total_count,
    hom_ref_count,
    het_count,
    hom_alt_count,
    hom_ref_freq,
    het_freq,
    hom_alt_freq,
  FROM (
    SELECT
      reference_name,
      start,
      END,
      reference_bases,
      alt,
      vt,
      alt_freq_from_1KG,
      # 1000 genomes data IS bi-allelic so there IS only ever a single alt
      # We also exclude calls _where one _or both alleles were NOT called (-1)
      SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS total_count,
      SUM(0 = first_allele
        AND 0 = second_allele) WITHIN RECORD AS hom_ref_count,
      SUM((0 = first_allele
          AND 1 = second_allele)
        OR (1 = first_allele
          AND 0 = second_allele)) WITHIN RECORD AS het_count,
      SUM(1 = first_allele
        AND 1 = second_allele) WITHIN RECORD AS hom_alt_count,
      SUM(0 = first_allele
        AND 0 = second_allele) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS hom_ref_freq,
      SUM((0 = first_allele
          AND 1 = second_allele)
        OR (1 = first_allele
          AND 0 = second_allele)) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS het_freq,
      SUM(1 = first_allele
        AND 1 = second_allele) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS hom_alt_freq,
    FROM (
      SELECT
        reference_name,
        start,
        END,
        reference_bases,
        GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
        vt,
        # Also return the pre-computed allelic frequency to help us check our work
        af AS alt_freq_from_1KG,
        NTH(1,
          call.genotype) WITHIN call AS first_allele,
        NTH(2,
          call.genotype) WITHIN call AS second_allele,
      FROM
        [genomics-public-data:1000_genomes.variants]
      WHERE
        reference_name = '17'
        AND start BETWEEN 41196311
        AND 41277499
        )))
ORDER BY
  reference_name,
  start

# The following query computes the allelic frequency for BRCA1 variants in the 
# PGP dataset _without_ using a user-defined function.
#
# Since without UDFs we cannot _count the other reference calls just assume
# the total number of alleles IS number of samples times 2 (thereby losing the
# distinction _between reference calls _and no-calls unfortunately)
SELECT
  contig_name,
  start_pos,
  reference_bases,
  alt,
  alt_allele_count / (174 * 2) AS alt_allele_frequency,
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases,
    alt,
    SUM(ref_allele_count) AS ref_allele_count,
    SUM(alt_allele_count) AS alt_allele_count,
    SUM(other_alt_allele_count) AS other_alt_allele_count,
  FROM (
    SELECT
      contig_name,
      start_pos,
      reference_bases,
      NTH(1,
        alternate_bases) WITHIN RECORD AS alt,
      SUM(IF(0 = call.genotype,
          1,
          0)) WITHIN RECORD AS ref_allele_count,
      SUM(IF(1 = call.genotype,
          1,
          0)) WITHIN RECORD AS alt_allele_count,
      SUM(IF(0 != call.genotype
          AND 1 != call.genotype,
          1,
          0)) WITHIN RECORD AS other_alt_allele_count,
    FROM
      [google.com:biggene:pgp.gvcf_variants]
    WHERE
      reference_bases != 'N'
      AND contig_name = '17'
      AND start_pos BETWEEN 41196312
      AND 41277500
      ),
    (
    SELECT
      contig_name,
      start_pos,
      reference_bases,
      NTH(2,
        alternate_bases) WITHIN RECORD AS alt,
      SUM(IF(0 = call.genotype,
          1,
          0)) WITHIN RECORD AS ref_allele_count,
      SUM(IF(2 = call.genotype,
          1,
          0)) WITHIN RECORD AS alt_allele_count,
      SUM(IF(0 != call.genotype
          AND 2 != call.genotype,
          1,
          0)) WITHIN RECORD AS other_alt_allele_count,
    FROM
      [google.com:biggene:pgp.gvcf_variants]
    WHERE
      reference_bases != 'N'
      AND contig_name = '17'
      AND start_pos BETWEEN 41196312
      AND 41277500
      )
  WHERE
    alt IS NOT NULL
  GROUP BY
    contig_name,
    start_pos,
    reference_bases,
    alt
    )
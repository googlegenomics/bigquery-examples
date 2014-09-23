# Count the number of variants shared by none, shared by one sample, two samples, etc...
SELECT
  num_samples_with_variant,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    SUM(first_allele > 0
      OR second_allele > 0) AS num_samples_with_variant
  FROM(
    SELECT
      contig_name,
      start_pos,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      [google.com:biggene:1000genomes.phase1_variants])
  GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases,
    alt
    )
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant

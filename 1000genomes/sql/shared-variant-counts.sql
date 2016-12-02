-- Count the number of variants shared by none, shared by one sample, two samples, etc...
SELECT
  num_samples_with_variant,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alternate_bases[ORDINAL(1)] AS alt,  -- 1000 Genomes is biallelic.
    (SELECT COUNTIF(EXISTS(SELECT gt
                          FROM UNNEST(call.genotype) gt
                          WHERE gt >= 1)) FROM v.call) AS num_samples_with_variant
  FROM
    `genomics-public-data.1000_genomes.variants` v
  WHERE
    reference_name NOT IN ("X", "Y", "MT"))
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant

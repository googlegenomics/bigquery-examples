SELECT
  COUNT(sample)AS cnt
FROM
  [google.com:biggene:1000genomes.sample_info]
WHERE
  In_Phase1_Integrated_Variant_Set = TRUE;
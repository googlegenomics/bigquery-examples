#standardSQL
--
-- Get the proportion of variants (per chromosome) in the dataset
-- that have been reported in the dbSNP database (version 132).
--
WITH
  counts AS (
  SELECT
    reference_name,
    COUNT(1) AS num_variants,
    COUNTIF(ARRAY_LENGTH(names) > 0) AS num_dbsnp_variants
  FROM
    `genomics-public-data.1000_genomes.variants`
  GROUP BY
    reference_name )
  --
  -- Compute the ratio.
SELECT
  reference_name,
  num_dbsnp_variants,
  num_variants,
  num_dbsnp_variants / num_variants AS frequency
FROM
  counts
ORDER BY
  num_variants DESC

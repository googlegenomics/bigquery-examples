# Inner SELECT filters just the records in which we are interested
# Outer SELECT performs our analysis, in this case just a count of the genotypes
# at a particular position in chromosome 3.
SELECT
  contig_name,
  start_pos,
  ref,
  alt,
  genotype,
  COUNT(genotype) AS cnt,
FROM (
  SELECT
    contig_name,
    start_pos,
    reference_bases AS ref,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    call.callset_name AS sample_id,
    call.gt AS genotype,
    call.gl AS likelihood,
  FROM
    [google.com:biggene:pgp.variants]
  WHERE
    contig_name = '3'
    AND start_pos = 65440410)
GROUP BY
  contig_name,
  start_pos,
  ref,
  alt,
  genotype
ORDER BY
  alt,
  cnt DESC;

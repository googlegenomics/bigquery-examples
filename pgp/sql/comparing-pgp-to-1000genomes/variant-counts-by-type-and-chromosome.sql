# Count the number of variants by variant type and chromosome.
SELECT
  contig_name,
  vt,
  cnt,
  dataset
FROM (
  SELECT
    contig_name,
    CASE
    WHEN (svtype IS NULL
      AND ref_len = 1
      AND alt_len = 1) THEN "SNP"
    WHEN (svtype IS NULL) THEN "INDEL"
    ELSE svtype END AS vt,
    COUNT(1) AS cnt,
    'PGP' AS dataset
  FROM (
    SELECT
      contig_name,
      svtype,
      LENGTH(reference_bases) AS ref_len,
      MAX(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
    FROM
      [google.com:biggene:pgp.variants]
      )
  GROUP BY
    contig_name,
    vt
    ),
  (
  SELECT
    contig AS contig_name,
    vt,
    COUNT(1) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [google.com:biggene:1000genomes.phase1_variants]
  GROUP BY
    contig_name,
    vt
    ),
ORDER BY
  contig_name,
  vt;
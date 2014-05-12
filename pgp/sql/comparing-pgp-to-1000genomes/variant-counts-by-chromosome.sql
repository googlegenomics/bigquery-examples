# Count the number of variants per chromosome.
SELECT
  contig_name,
  cnt,
  dataset
FROM (
  SELECT
    contig AS contig_name,
    COUNT(1) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  GROUP BY
    contig_name
    ),
  (
  SELECT
    contig_name,
    COUNT(1) AS cnt,
    'PGP' AS dataset
  FROM
    [google.com:biggene:pgp.variants]
  GROUP BY
    contig_name)
ORDER BY
  contig_name;


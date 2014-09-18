# Compute the Ti/Tv ratio of the 1,000 Genomes dataset.
SELECT
  transitions,
  transversions,
  transitions/transversions AS titv
FROM (
  SELECT
    SUM(IF(mutation IN ('A->G',
          'G->A',
          'C->T',
          'T->C'),
        INTEGER(num_snps),
        INTEGER(0))) AS transitions,
    SUM(IF(mutation IN ('A->C',
          'C->A',
          'G->T',
          'T->G',
          'A->T',
          'T->A',
          'C->G',
          'G->C'),
        INTEGER(num_snps),
        INTEGER(0))) AS transversions,
  FROM (
    SELECT
      CONCAT(reference_bases,
        CONCAT(STRING('->'),
          alternate_bases)) AS mutation,
      COUNT(alternate_bases) AS num_snps,
    FROM
      [google.com:biggene:1000genomes.phase1_variants]
    WHERE
      vt = 'SNP'
    GROUP BY
      mutation
    ORDER BY
      mutation));

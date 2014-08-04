# Compute the Ti/Tv ratio for each participant in the PGP dataset.
SELECT
  sample_id,
  transitions,
  transversions,
  transitions/transversions AS titv
FROM (
  SELECT
    sample_id,
    SUM(IF(mutation1 IN ('A->G',
          'G->A',
          'C->T',
          'T->C'),
        1,
        0) + IF(mutation2 IN ('A->G',
          'G->A',
          'C->T',
          'T->C'),
        1,
        0)) AS transitions,
    SUM(IF(mutation1 IN ('A->C',
          'C->A',
          'G->T',
          'T->G',
          'A->T',
          'T->A',
          'C->G',
          'G->C'),
        1,
        0) + IF(mutation2 IN ('A->C',
          'C->A',
          'G->T',
          'T->G',
          'A->T',
          'T->A',
          'C->G',
          'G->C'),
        1,
        0)) AS transversions,
  FROM (
    SELECT
      sample_id,
      CONCAT(reference,
        CONCAT(STRING('->'),
          allele1Seq)) AS mutation1,
      CONCAT(reference,
        CONCAT(STRING('->'),
          allele2Seq)) AS mutation2,
    FROM
      [google.com:biggene:pgp.cgi_variants]
    WHERE
      # WHERE varType = 'snp' not correct since a row with both an indel
      # and a snp will be varType 'complex'
      reference != '='
      AND LENGTH(reference) = 1
      )
  GROUP BY
    sample_id)
ORDER BY
  titv DESC

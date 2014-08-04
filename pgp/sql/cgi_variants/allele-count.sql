# Count the occurence of each variant allele across all participants in the
# dataset.  This returns a large result so be sure to materialize it into a
# table for subsequent use. 
SELECT
  chromosome,
  reference,
  INTEGER(FLOOR(locusBegin / 5000)) AS bin,
  locusBegin,
  locusEnd,
  allele,
  SUM(cnt) AS alternate_allele_count,
FROM (
  SELECT
    chromosome,
    reference,
    locusBegin,
    locusEnd,
    allele1Seq AS allele,
    COUNT(1) AS cnt
  FROM
    [google.com:biggene:pgp.cgi_variants] 
  WHERE
    (reference != '=' OR reference IS NULL)
    AND allele1Seq != '?'
    AND (reference != allele1Seq OR reference IS NULL)
  GROUP EACH BY
    chromosome,
    reference,
    locusBegin,
    locusEnd,
    allele),
  (
  SELECT
    chromosome,
    reference,
    locusBegin,
    locusEnd,
    allele2Seq AS allele,
    COUNT(1) AS cnt
  FROM
    [google.com:biggene:pgp.cgi_variants]
  WHERE
    (reference != '=' OR reference IS NULL)
    AND allele2Seq != '?'
    AND (reference != allele2Seq OR reference IS NULL)
  GROUP EACH BY
    chromosome,
    reference,
    locusBegin,
    locusEnd,
    allele)
GROUP EACH BY
  chromosome,
  reference,
  bin,
  locusBegin,
  locusEnd,
  allele
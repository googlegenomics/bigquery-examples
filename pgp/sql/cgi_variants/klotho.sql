# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story. 
SELECT
  sample_id,
  chromosome,
  locusBegin,
  locusEnd,
  reference,
  allele1Seq,
  allele2Seq,
FROM
  [google.com:biggene:pgp.cgi_variants]
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138
ORDER BY
  sample_id

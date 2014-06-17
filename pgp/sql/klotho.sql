# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story. 
SELECT
  *
FROM
  [google.com:biggene:pgp.cgi_variants]
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138

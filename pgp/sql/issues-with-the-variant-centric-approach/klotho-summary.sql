# Sample counts for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story. 
SELECT
  COUNT(sample_id) AS sample_counts,
  chromosome,
  reference,
  allele1Seq,
  allele2Seq,
FROM
  [google.com:biggene:pgp.cgi_variants]
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138
GROUP BY
  chromosome,
  reference,
  allele1Seq,
  allele2Seq
ORDER BY
  sample_counts DESC

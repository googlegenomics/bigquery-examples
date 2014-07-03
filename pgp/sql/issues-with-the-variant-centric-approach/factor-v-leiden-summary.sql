# Summary data for rs6025 and hereditary thrombophilia trait  
# for use in the Factor V Leiden data story. 
 SELECT
  COUNT(sample_id) AS sample_counts,
  chromosome,
  reference,
  allele1Seq,
  allele2Seq,
  has_Hereditary_thrombophilia_includes_Factor_V_Leiden_and_Prothrombin_G20210A AS has_Hereditary_thrombophilia
FROM
  [google.com:biggene:pgp.cgi_variants] AS var
LEFT OUTER JOIN
  [google.com:biggene:pgp.phenotypes] AS pheno
ON
  pheno.Participant = var.sample_id
  WHERE
  chromosome = 'chr1'
  AND locusBegin <= 169519048
  AND locusEnd >= 169519049
GROUP BY
  chromosome,
  reference,
  allele1Seq,
  allele2Seq,
  has_Hereditary_thrombophilia
ORDER BY
  sample_counts DESC

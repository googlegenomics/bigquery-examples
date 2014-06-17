# Sample level data for rs6025 and hereditary thrombophilia trait  
# for use in the Factor V Leiden data story. 
 SELECT
  sample_id,
  chromosome,
  locusBegin,
  locusEnd,
  reference,
  allele1Seq,
  allele2Seq,
  zygosity,
  has_Hereditary_thrombophilia_includes_Factor_V_Leiden_and_Prothrombin_G20210A
FROM
  [google.com:biggene:pgp.cgi_variants] AS var
JOIN
  [google.com:biggene:pgp.phenotypes] AS pheno
ON
  pheno.Participant = var.sample_id
  WHERE
  chromosome = 'chr1'
  AND locusBegin <= 169519048
  AND locusEnd >= 169519049

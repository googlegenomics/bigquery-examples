SELECT
  clinvar.clinical_significance AS clinical_significance,
  names.diseasename AS disease_name,
  COUNT(*) AS num_variants
FROM (
  SELECT
    clin.clinicalsignificance AS clinical_significance,
    REGEXP_EXTRACT(phenotypeids,
      r'MedGen:(\w+)') AS disease_id,
  FROM
    [google.com:biggene:1000genomes.variants1kG] var
  JOIN
    [google.com:biggene:1000genomes.clinvar] clin
  ON
    var.contig = clin.chromosome
    AND var.position = clin.start
  WHERE
    var.vt='SNP'
    AND clin.type='single nucleotide variant'
    ) AS clinvar
JOIN
  [google.com:biggene:1000genomes.clinvar_disease_names] AS names
ON
  names.conceptid = clinvar.disease_id
GROUP BY
  clinical_significance,
  disease_name
ORDER BY
  disease_name,
  clinical_significance;
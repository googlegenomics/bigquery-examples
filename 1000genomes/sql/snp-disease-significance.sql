# Summarize all the SNPs in 1,000 Genomes also found in ClinVar by significance
# and disease name.
SELECT
  clinicalsignificance,
  diseasename,
  COUNT(1) AS num_variants
FROM (
  SELECT
    clinicalsignificance,
    disease_id
  FROM
    FLATTEN([google.com:biggene:1000genomes.variants1kG],
      alternate_bases) AS var
  JOIN (
    SELECT
      chromosome,
      start,
      clinicalsignificance,
      REGEXP_EXTRACT(hgvs_c,
        r'(\w)>\w') AS ref,
      REGEXP_EXTRACT(hgvs_c,
        r'\w>(\w)')  AS alt,
      REGEXP_EXTRACT(phenotypeids,
        r'MedGen:(\w+)') AS disease_id,
    FROM
      [google.com:biggene:1000genomes.clinvar]
    WHERE
      type='single nucleotide variant'
      ) AS clin
  ON
    var.contig = clin.chromosome
    AND var.position = clin.start
    AND reference_bases = ref
    AND alternate_bases = alt
  WHERE
    var.vt='SNP') AS sig
JOIN
  [google.com:biggene:1000genomes.clinvar_disease_names] AS names
ON
  names.conceptid = sig.disease_id
GROUP BY
  clinicalsignificance,
  diseasename,
ORDER BY
  num_variants DESC;

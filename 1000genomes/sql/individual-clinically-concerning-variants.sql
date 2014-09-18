# Retrieve the SNPs identified by ClinVar as pathenogenic or a risk factor for a particular sample
SELECT
  contig_name,
  start_pos,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
FROM (
  SELECT
    contig_name,
    start_pos,
    ref,
    alt,
    call.callset_name AS sample_id,
    clinicalsignificance,
    disease_id,
  FROM
    FLATTEN([google.com:biggene:1000genomes.phase1_variants],
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
      [google.com:biggene:annotations.clinvar]
    WHERE
      type='single nucleotide variant'
      AND (clinicalsignificance CONTAINS 'risk factor'
        OR clinicalsignificance CONTAINS 'pathogenic'
        OR clinicalsignificance CONTAINS 'Pathogenic')
      ) AS clin
  ON
    var.contig_name = clin.chromosome
    AND var.start_pos = clin.start
    AND reference_bases = ref
    AND alternate_bases = alt
  WHERE
    call.callset_name = 'NA19764'
    AND var.vt='SNP'
    AND (var.call.first_allele > 0
      OR var.call.second_allele > 0)) AS sig
JOIN
  [google.com:biggene:annotations.clinvar_disease_names] AS names
ON
  names.conceptid = sig.disease_id
GROUP BY
  contig_name,
  start_pos,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
ORDER BY
  clinicalsignificance,
  contig_name,
  start_pos;

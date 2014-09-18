# Retrieve the SNPs identified by ClinVar as pathenogenic or a risk factor, counting the 
# number of family members sharing the SNP
SELECT
  contig_name,
  start_pos,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
FROM (
  SELECT
    contig_name,
    start_pos,
    ref,
    alt,
    clinicalsignificance,
    disease_id,
    family_id,
    COUNT(*) AS num_family_members_with_variant,
  FROM
    (FLATTEN(
        (
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
          var.vt='SNP'
          AND (var.call.first_allele > 0
            OR var.call.second_allele > 0)),
        var.call)) AS sig
  JOIN
    [google.com:biggene:1000genomes.pedigree] AS ped
  ON
    sig.sample_id = ped.individual_id
  GROUP BY
    contig_name,
    start_pos,
    ref,
    alt,
    clinicalsignificance,
    disease_id,
    family_id) families
JOIN
  [google.com:biggene:annotations.clinvar_disease_names] AS names
ON
  names.conceptid = families.disease_id
GROUP BY
  contig_name,
  start_pos,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
ORDER BY
  num_family_members_with_variant DESC,
  clinicalsignificance,
  contig_name,
  start_pos

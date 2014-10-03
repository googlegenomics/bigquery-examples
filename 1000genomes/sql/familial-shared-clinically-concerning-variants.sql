# Retrieve the SNPs identified by ClinVar as pathenogenic or a risk factor, counting the
# number of family members sharing the SNP
SELECT
  reference_name,
  start,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
FROM (
  SELECT
    reference_name,
    start,
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
          reference_name,
          var.start AS start,
          ref,
          alt,
          call.call_set_name AS sample_id,
          NTH(1,
            call.genotype) WITHIN var.call AS first_allele,
          NTH(2,
            call.genotype) WITHIN var.call AS second_allele,
          clinicalsignificance,
          disease_id,
        FROM
          FLATTEN([genomics-public-data:1000_genomes.variants],
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
          var.reference_name = clin.chromosome
          AND var.start = clin.start
          AND reference_bases = ref
          AND alternate_bases = alt
        WHERE
          var.vt='SNP'
        HAVING
          first_allele > 0
          OR (second_allele IS NOT NULL
              AND second_allele > 0)),
        var.call)) AS sig
  JOIN
    [genomics-public-data:1000_genomes.pedigree] AS ped
  ON
    sig.sample_id = ped.individual_id
  GROUP BY
    reference_name,
    start,
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
  reference_name,
  start,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
ORDER BY
  num_family_members_with_variant DESC,
  clinicalsignificance,
  reference_name,
  start,
  family_id

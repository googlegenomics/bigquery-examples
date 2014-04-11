SELECT
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
FROM (
  SELECT
    contig,
    position,
    ref,
    alt,
    genotype.sample_id AS sample_id,
    clinicalsignificance,
    disease_id,
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
      AND (clinicalsignificance CONTAINS 'risk factor'
        OR clinicalsignificance CONTAINS 'pathogenic'
        OR clinicalsignificance CONTAINS 'Pathogenic')
      ) AS clin
  ON
    var.contig = clin.chromosome
    AND var.position = clin.start
    AND reference_bases = ref
    AND alternate_bases = alt
  WHERE
    genotype.sample_id = 'NA19764'
    AND var.vt='SNP'
    AND (var.genotype.first_allele != 0
      OR var.genotype.second_allele != 0)) AS sig
JOIN
  [google.com:biggene:1000genomes.clinvar_disease_names] AS names
ON
  names.conceptid = sig.disease_id
GROUP BY
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
ORDER BY
  clinicalsignificance,
  contig,
  position;

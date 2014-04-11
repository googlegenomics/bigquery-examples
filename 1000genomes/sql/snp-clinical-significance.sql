SELECT
  clin.clinicalsignificance AS clinical_significance,
  COUNT(clin.clinicalsignificance) AS cnt
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
GROUP BY
  clinical_significance
ORDER BY
  cnt DESC;

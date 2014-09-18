# Scan the entirety of 1,000 Genomes counting the number of variants found 
# within the BRCA1 and APOE genes
SELECT
  gene_variants.name AS name,
  contig_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    name,
    var.contig_name AS contig_name,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      contig_name,
      start_pos AS variant_start,
      IF(vt != 'SV',
        start_pos + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      [google.com:biggene:1000genomes.phase1_variants]) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS contig_name,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:annotations.known_genes] ) AS genes
  ON
    var.contig_name = genes.contig_name
  WHERE
    (( var.variant_start <= var.variant_end
        AND NOT (
          var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
      OR (var.variant_start <= var.variant_end
        AND NOT (
          var.variant_end > genes.gene_end || var.variant_start < genes.gene_start)))
  GROUP BY
    name,
    contig_name,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:annotations.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  name,
  contig_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt
HAVING
  gene_aliases CONTAINS 'BRCA1'
  OR gene_aliases CONTAINS 'APOE';
# Count the number of variants per gene within chromosome 17
SELECT
  gene_variants.name AS name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    name,
    var.contig AS contig,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      contig,
      position AS variant_start,
      IF(vt != 'SV',
        position + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      [google.com:biggene:1000genomes.phase1_variants]) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS contig,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:annotations.known_genes] ) AS genes
  ON
    var.contig = genes.contig
  WHERE
    var.contig = '17'
    AND (( var.variant_start <= var.variant_end
        AND NOT (
          var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
      OR (var.variant_start <= var.variant_end
        AND NOT (
          var.variant_end > genes.gene_end || var.variant_start < genes.gene_start)))
  GROUP BY
    name,
    contig,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:annotations.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt

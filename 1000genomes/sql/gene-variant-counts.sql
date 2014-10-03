# Count the number of variants per gene within chromosome 17.
# TODO: double check whether the annotation coordinates are 0-based as is
#       the case for the variants.
SELECT
  gene_variants.name AS name,
  reference_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    name,
    var.reference_name AS reference_name,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      reference_name,
      start AS variant_start,
      IF(vt != 'SV',
        start + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      [genomics-public-data:1000_genomes.variants]) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS reference_name,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:annotations.known_genes] ) AS genes
  ON
    var.reference_name = genes.reference_name
  WHERE
    var.reference_name = '17'
    AND (( var.variant_start <= var.variant_end
        AND NOT (
          var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
      OR (var.variant_start <= var.variant_end
        AND NOT (
          var.variant_end > genes.gene_end || var.variant_start < genes.gene_start)))
  GROUP BY
    name,
    reference_name,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:annotations.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  name,
  reference_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt
ORDER BY
  name,
  reference_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt

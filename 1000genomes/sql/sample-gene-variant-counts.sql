# Count the number of variants per gene within chromosome 17 for a particular sample.
# TODO: double check whether the annotation coordinates are 0-based as is
#       the case for the variants.
SELECT
  sample_id,
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
    sample_id,
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
      call.call_set_name AS sample_id,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      FLATTEN([genomics-public-data:1000_genomes.variants],
        alternate_bases)
    WHERE
      reference_name = '17'
      AND call.call_set_name = 'NA19764'
    HAVING
      first_allele > 0
      OR (second_allele IS NOT NULL
            AND second_allele > 0)
      ) AS var
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
    ( var.variant_start <= var.variant_end
      AND NOT (
        var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
    OR (var.variant_start <= var.variant_end
      AND NOT (
        var.variant_end > genes.gene_end || var.variant_start < genes.gene_start))
  GROUP BY
    sample_id,
    name,
    reference_name,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:annotations.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  sample_id,
  name,
  reference_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt
ORDER BY
  sample_id,
  name,
  reference_name,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt

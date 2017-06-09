#standardSQL
  --
  -- Count SNPs by functional impact for each sample in Platinum Genomes.
  --
WITH
  sample_variants AS (
  SELECT
    REGEXP_EXTRACT(reference_name, r'chr(.+)') AS chr,
    start AS start,
    reference_bases,
    alt,
    call.call_set_name
  FROM
    `genomics-public-data.platinum_genomes.variants` v,
    v.call call,
    v.alternate_bases alt WITH OFFSET alt_offset
  WHERE
    -- Require that at least one genotype matches this alternate.
    EXISTS (SELECT gt FROM UNNEST(call.genotype) gt WHERE gt = alt_offset+1)
    )
  --
  --
SELECT
  call_set_name,
  ExonicFunc,
  COUNT(ExonicFunc) AS variant_count
FROM
  `silver-wall-555.TuteTable.hg19` AS annots
JOIN sample_variants AS vars
ON
  vars.chr = annots.Chr
  AND vars.start = annots.Start
  AND vars.reference_bases = annots.Ref
  AND vars.alt = annots.Alt
WHERE
  ExonicFunc IS NOT NULL
GROUP BY
  call_set_name,
  ExonicFunc
ORDER BY
  call_set_name,
  ExonicFunc

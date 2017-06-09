#standardSQL
  --
  -- Return SNPs for sample NA12878 that are:
  --   annotated as 'pathogenic' in ClinVar
  --   with observed population frequency less than 1%
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
    call_set_name = 'NA12878'
    -- Require that at least one genotype matches this alternate.
    AND EXISTS (SELECT gt FROM UNNEST(call.genotype) gt WHERE gt = alt_offset+1) )
  --
  --
SELECT
  call_set_name,
  annots.Chr,
  annots.Start,
  Ref,
  annots.Alt,
  Func,
  Gene,
  PopFreqMax,
  ExonicFunc,
  ClinVar_SIG,
  ClinVar_DIS
FROM
  `silver-wall-555.TuteTable.hg19` AS annots
JOIN
  sample_variants AS vars
ON
  vars.chr = annots.Chr
  AND vars.start = annots.Start
  AND vars.reference_bases = annots.Ref
  AND vars.alt = annots.Alt
WHERE
  PopFreqMax <= 0.01
  AND ClinVar_SIG LIKE '%pathogenic%'
  AND NOT CLinVar_SIG LIKE '%non-pathogenic%'
ORDER BY
  Chr,
  Start,
  Ref,
  Alt,
  call_set_name

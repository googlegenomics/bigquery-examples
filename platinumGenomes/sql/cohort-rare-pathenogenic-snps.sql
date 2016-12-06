  -- Return all SNPs from the Platinum Genomes cohort that are:
  --   annotated as 'pathogenic' in ClinVar
  --   with observed population frequency less than 1%
WITH
  cohort_variants AS (
  SELECT
    REGEXP_EXTRACT(reference_name, r'chr(.+)') AS chr,
    start AS start,
    reference_bases,
    alt
  FROM
    `genomics-public-data.platinum_genomes.variants` v,
    v.alternate_bases alt WITH OFFSET alt_offset
  WHERE
    -- Require that at least one sample in the cohort has this variant.
    EXISTS(SELECT gt FROM UNNEST(v.call) call, UNNEST(call.genotype) gt WHERE gt = alt_offset+1)
    )
  --
  --
SELECT
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
  cohort_variants AS vars
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
  Alt

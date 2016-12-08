Platinum Genomes
================

### Additional Resources

There are just a handful of queries below but you will find a whole suite of
queries for the Platinum Genome dataset written as a codelab for performing
[Quality Control on Variants](https://github.com/googlegenomics/codelabs/tree/master/R/PlatinumGenomes-QC).

* [variants table](https://bigquery.cloud.google.com/table/genomics-public-data:platinum_genomes.variants?pli=1)
* [sample_info table](https://bigquery.cloud.google.com/table/google.com:biggene:platinum_genomes.sample_info)
* See [Google Genomics Public Data](http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/platinum_genomes.html)
for provenance details for this data.





### SNP Annotation

Let's annotate variants in the [Illumina Platinum Genomes dataset](http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/platinum_genomes.html)
using Tute Genomics' table of annotations for hg19 SNPs.  Please see [Google Genomics Public Data](http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/tute_genomics_public_data.html)
for more detail about these annotations.

First we'll count variants by exonic functional impact:

```
  -- Count SNPs by functional impact for each sample in Platinum Genomes.
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
```

Results:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Mon Dec  5 14:37:49 2016 -->
<table border=1>
<tr> <th> call_set_name </th> <th> ExonicFunc </th> <th> variant_count </th>  </tr>
  <tr> <td> NA12877 </td> <td> missense </td> <td align="right">   13377 </td> </tr>
  <tr> <td> NA12877 </td> <td> nonsense </td> <td align="right">     116 </td> </tr>
  <tr> <td> NA12877 </td> <td> silent </td> <td align="right">   13313 </td> </tr>
  <tr> <td> NA12877 </td> <td> stoploss </td> <td align="right">      18 </td> </tr>
  <tr> <td> NA12878 </td> <td> missense </td> <td align="right">   13399 </td> </tr>
  <tr> <td> NA12878 </td> <td> nonsense </td> <td align="right">     115 </td> </tr>
   </table>

Visualized:
<img src="figure/function-1.png" title="plot of chunk function" alt="plot of chunk function" style="display: block; margin: auto;" />

Next we'll identify rare variants across the cohort indicated as pathenogenic
by [ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/):

```
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
```

Results:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Mon Dec  5 14:37:54 2016 -->
<table border=1>
<tr> <th> Chr </th> <th> Start </th> <th> Ref </th> <th> Alt </th> <th> Func </th> <th> Gene </th> <th> PopFreqMax </th> <th> ExonicFunc </th> <th> ClinVar_SIG </th> <th> ClinVar_DIS </th>  </tr>
  <tr> <td> 1 </td> <td align="right"> 155205633 </td> <td> T </td> <td> C </td> <td> exonic </td> <td> GBA </td> <td align="right"> 0.002800 </td> <td> missense </td> <td> pathogenic|other|other|pathogenic </td> <td> Gaucher's_disease,_type_1|Parkinson_disease,_late-onset,_susceptibility_to|Dementia,_Lewy_body,_susceptibility_to|not_provided;Gaucher_disease </td> </tr>
  <tr> <td> 11 </td> <td align="right"> 6638384 </td> <td> C </td> <td> T </td> <td> splicing </td> <td> TPP1 </td> <td align="right"> 0.001000 </td> <td>  </td> <td> pathogenic|pathogenic </td> <td> Ceroid_lipofuscinosis,_neuronal,_2|Spinocerebellar_ataxia,_autosomal_recessive_7 </td> </tr>
  <tr> <td> 12 </td> <td align="right"> 103234251 </td> <td> T </td> <td> C </td> <td> exonic </td> <td> PAH </td> <td align="right"> 0.001000 </td> <td> missense </td> <td> pathogenic|pathogenic </td> <td> Hyperphenylalaninemia,_non-pku|not_provided </td> </tr>
  <tr> <td> 15 </td> <td align="right"> 89870431 </td> <td> C </td> <td> T </td> <td> exonic </td> <td> POLG </td> <td align="right"> 0.001400 </td> <td> missense </td> <td> pathogenic|pathogenic|pathogenic|pathogenic </td> <td> Cerebellar_ataxia_infantile_with_progressive_external_ophthalmoplegia|Sensory_ataxic_neuropathy,_dysarthria,_and_ophthalmoparesis|Myoclonic_epilepsy_myopathy_sensory_ataxia|Progressive_sclerosing_poliodystrophy </td> </tr>
  <tr> <td> 16 </td> <td align="right"> 29825021 </td> <td> C </td> <td> T </td> <td> exonic </td> <td> PRRT2 </td> <td align="right"> 0.010000 </td> <td> missense </td> <td> pathogenic </td> <td> Dystonia_10;not_specified|not_provided </td> </tr>
  <tr> <td> 6 </td> <td align="right"> 161127500 </td> <td> A </td> <td> G </td> <td> exonic </td> <td> PLG </td> <td align="right"> 0.008900 </td> <td> missense </td> <td> pathogenic </td> <td> PLASMINOGEN_DEFICIENCY,_TYPE_I </td> </tr>
  <tr> <td> 7 </td> <td align="right"> 87060843 </td> <td> C </td> <td> T </td> <td> exonic </td> <td> ABCB4 </td> <td align="right"> 0.010000 </td> <td> missense </td> <td> pathogenic|pathogenic </td> <td> Cholestasis,_intrahepatic,_of_pregnancy_3|Cholecystitis </td> </tr>
  <tr> <td> 7 </td> <td align="right"> 117227791 </td> <td> G </td> <td> A </td> <td> splicing </td> <td> CFTR </td> <td align="right"> 0.001400 </td> <td>  </td> <td> pathogenic </td> <td> Cystic_fibrosis </td> </tr>
  <tr> <td> 7 </td> <td align="right"> 143048770 </td> <td> C </td> <td> T </td> <td> exonic </td> <td> CLCN1 </td> <td align="right"> 0.008000 </td> <td> nonsense </td> <td> pathogenic|pathogenic|pathogenic </td> <td> Congenital_myotonia,_autosomal_recessive_form|Congenital_myotonia,_autosomal_dominant_form|Myotonia_congenita </td> </tr>
  <tr> <td> 7 </td> <td align="right"> 150884002 </td> <td> C </td> <td> T </td> <td> exonic </td> <td> ASB10 </td> <td align="right"> 0.004000 </td> <td> missense </td> <td> pathogenic </td> <td> Glaucoma_1,_open_angle,_F </td> </tr>
  <tr> <td> 8 </td> <td align="right"> 106431419 </td> <td> A </td> <td> G </td> <td> exonic </td> <td> ZFPM2 </td> <td align="right"> 0.006000 </td> <td> missense </td> <td> pathogenic|pathogenic </td> <td> Tetralogy_of_Fallot|Double_outlet_right_ventricle </td> </tr>
   </table>

And finally we'll re-run this analysis using only the variants for one specific individual:

```
  -- Return SNPs for sample NA12878 that are:
  --   annotated as 'pathogenic' in ClinVar
  --   with observed population frequency less than 1%
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
```

Results:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Mon Dec  5 14:37:59 2016 -->
<table border=1>
<tr> <th> call_set_name </th> <th> Chr </th> <th> Start </th> <th> Ref </th> <th> Alt </th> <th> Func </th> <th> Gene </th> <th> PopFreqMax </th> <th> ExonicFunc </th> <th> ClinVar_SIG </th> <th> ClinVar_DIS </th>  </tr>
  <tr> <td> NA12878 </td> <td> 11 </td> <td align="right"> 6638384 </td> <td> C </td> <td> T </td> <td> splicing </td> <td> TPP1 </td> <td align="right"> 0.001000 </td> <td>  </td> <td> pathogenic|pathogenic </td> <td> Ceroid_lipofuscinosis,_neuronal,_2|Spinocerebellar_ataxia,_autosomal_recessive_7 </td> </tr>
  <tr> <td> NA12878 </td> <td> 12 </td> <td align="right"> 103234251 </td> <td> T </td> <td> C </td> <td> exonic </td> <td> PAH </td> <td align="right"> 0.001000 </td> <td> missense </td> <td> pathogenic|pathogenic </td> <td> Hyperphenylalaninemia,_non-pku|not_provided </td> </tr>
  <tr> <td> NA12878 </td> <td> 6 </td> <td align="right"> 161127500 </td> <td> A </td> <td> G </td> <td> exonic </td> <td> PLG </td> <td align="right"> 0.008900 </td> <td> missense </td> <td> pathogenic </td> <td> PLASMINOGEN_DEFICIENCY,_TYPE_I </td> </tr>
   </table>

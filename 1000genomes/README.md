<!-- R Markdown Documentation, DO NOT EDIT THE PLAIN MARKDOWN VERSION OF THIS FILE -->

<!-- Copyright 2014 Google Inc. All rights reserved. -->

<!-- Licensed under the Apache License, Version 2.0 (the "License"); -->
<!-- you may not use this file except in compliance with the License. -->
<!-- You may obtain a copy of the License at -->

<!--     http://www.apache.org/licenses/LICENSE-2.0 -->

<!-- Unless required by applicable law or agreed to in writing, software -->
<!-- distributed under the License is distributed on an "AS IS" BASIS, -->
<!-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. -->
<!-- See the License for the specific language governing permissions and -->
<!-- limitations under the License. -->

1,000 Genomes
=================

### Additional Resources
* [Schema](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.variants?pli=1)
* [Provenance](./provenance)
* [Data Stories](./data-stories) such as
 * [Exploring the phenotypic data](./data-stories/exploring-the-phenotypic-data)
 * [Exploring the variant data](./data-stories/exploring-the-variant-data)
 * [Understanding Alternate Alleles in 1,000 Genomes](./data-stories/understanding-alternate-alleles)
* [Index of variant analyses](./sql)

### Diving right in
The following query returns the proportion of variants that have been reported in the [dbSNP database](http://www.ncbi.nlm.nih.gov/projects/SNP/snp_summary.cgi?build_id=132) [version 132](http://www.1000genomes.org/category/variants), by chromosome, across the entirety of the 1,000 Genomes low coverage variant data for 1,092 individuals:






```
-- Get the proportion of variants (per chromosome) in the dataset
-- that have been reported in the dbSNP database (version 132).
WITH
  counts AS (
  SELECT
    reference_name,
    COUNT(1) AS num_variants,
    COUNTIF(ARRAY_LENGTH(names) > 0) AS num_dbsnp_variants
  FROM
    `genomics-public-data.1000_genomes.variants`
  GROUP BY
    reference_name )
  --
  -- Compute the ratio.
SELECT
  reference_name,
  num_dbsnp_variants,
  num_variants,
  num_dbsnp_variants / num_variants AS frequency
FROM
  counts
ORDER BY
  num_variants DESC
```

We see the tabular results:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:21 2016 -->
<table border=1>
<tr> <th> reference_name </th> <th> num_dbsnp_variants </th> <th> num_variants </th> <th> frequency </th>  </tr>
  <tr> <td> 2 </td> <td align="right"> 3301885 </td> <td align="right"> 3307592 </td> <td align="right"> 0.998275 </td> </tr>
  <tr> <td> 1 </td> <td align="right"> 3001739 </td> <td align="right"> 3007196 </td> <td align="right"> 0.998185 </td> </tr>
  <tr> <td> 3 </td> <td align="right"> 2758667 </td> <td align="right"> 2763454 </td> <td align="right"> 0.998268 </td> </tr>
  <tr> <td> 4 </td> <td align="right"> 2731973 </td> <td align="right"> 2736765 </td> <td align="right"> 0.998249 </td> </tr>
  <tr> <td> 5 </td> <td align="right"> 2525874 </td> <td align="right"> 2530217 </td> <td align="right"> 0.998284 </td> </tr>
  <tr> <td> 6 </td> <td align="right"> 2420027 </td> <td align="right"> 2424425 </td> <td align="right"> 0.998186 </td> </tr>
  <tr> <td> 7 </td> <td align="right"> 2211317 </td> <td align="right"> 2215231 </td> <td align="right"> 0.998233 </td> </tr>
  <tr> <td> 8 </td> <td align="right"> 2180311 </td> <td align="right"> 2183839 </td> <td align="right"> 0.998384 </td> </tr>
  <tr> <td> 11 </td> <td align="right"> 1891627 </td> <td align="right"> 1894908 </td> <td align="right"> 0.998269 </td> </tr>
  <tr> <td> 10 </td> <td align="right"> 1879337 </td> <td align="right"> 1882663 </td> <td align="right"> 0.998233 </td> </tr>
  <tr> <td> 12 </td> <td align="right"> 1824513 </td> <td align="right"> 1828006 </td> <td align="right"> 0.998089 </td> </tr>
  <tr> <td> 9 </td> <td align="right"> 1649563 </td> <td align="right"> 1652388 </td> <td align="right"> 0.998290 </td> </tr>
  <tr> <td> X </td> <td align="right"> 1482078 </td> <td align="right"> 1487477 </td> <td align="right"> 0.996370 </td> </tr>
  <tr> <td> 13 </td> <td align="right"> 1370342 </td> <td align="right"> 1373000 </td> <td align="right"> 0.998064 </td> </tr>
  <tr> <td> 14 </td> <td align="right"> 1255966 </td> <td align="right"> 1258254 </td> <td align="right"> 0.998182 </td> </tr>
  <tr> <td> 16 </td> <td align="right"> 1208679 </td> <td align="right"> 1210619 </td> <td align="right"> 0.998398 </td> </tr>
  <tr> <td> 15 </td> <td align="right"> 1128457 </td> <td align="right"> 1130554 </td> <td align="right"> 0.998145 </td> </tr>
  <tr> <td> 18 </td> <td align="right"> 1086823 </td> <td align="right"> 1088820 </td> <td align="right"> 0.998166 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 1044658 </td> <td align="right"> 1046733 </td> <td align="right"> 0.998018 </td> </tr>
  <tr> <td> 20 </td> <td align="right">  853680 </td> <td align="right">  855166 </td> <td align="right"> 0.998262 </td> </tr>
  <tr> <td> 19 </td> <td align="right">  814343 </td> <td align="right">  816115 </td> <td align="right"> 0.997829 </td> </tr>
  <tr> <td> 21 </td> <td align="right">  517920 </td> <td align="right">  518965 </td> <td align="right"> 0.997986 </td> </tr>
  <tr> <td> 22 </td> <td align="right">  493717 </td> <td align="right">  494328 </td> <td align="right"> 0.998764 </td> </tr>
  <tr> <td> Y </td> <td align="right">    3403 </td> <td align="right">   18728 </td> <td align="right"> 0.181707 </td> </tr>
  <tr> <td> MT </td> <td align="right">     585 </td> <td align="right">    2834 </td> <td align="right"> 0.206422 </td> </tr>
   </table>

And visually:
<img src="figure/dbSNP Variants-1.png" title="plot of chunk dbSNP Variants" alt="plot of chunk dbSNP Variants" style="display: block; margin: auto;" />

### Variant Metadata
The 1000 Genomes variant data is stored in the [variants](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.variants?pli=1) table.  Every record in the variants table maps to a single site (line) in the [VCF](http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41) file.  See the [schema](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.variants?pli=1) for more detail.

Show variants within BRCA1:

```
-- Retrieve variant-level information for BRCA1 variants.
SELECT
  reference_name,
  start,
  `end`,
  reference_bases,
  ARRAY_TO_STRING(v.alternate_bases, ',') AS alts,
  quality,
  ARRAY_TO_STRING(v.filter, ',') AS filter,
  ARRAY_TO_STRING(v.names, ',') AS names,
  vt,
  ARRAY_LENGTH(v.call) AS num_samples
FROM
  `genomics-public-data.1000_genomes.variants` v
WHERE
  reference_name IN ('17', 'chr17')
  AND start BETWEEN 41196311 AND 41277499 # per GRCh37
ORDER BY
  start,
  alts
```
Number of rows returned by this query: 879.

Examing the first few rows, we see:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:25 2016 -->
<table border=1>
<tr> <th> reference_name </th> <th> start </th> <th> end </th> <th> reference_bases </th> <th> alts </th> <th> quality </th> <th> filter </th> <th> names </th> <th> vt </th> <th> num_samples </th>  </tr>
  <tr> <td> 17 </td> <td align="right"> 41196362 </td> <td align="right"> 41196363 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs8176320,rs8176320 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196367 </td> <td align="right"> 41196368 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs184237074,rs184237074 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196371 </td> <td align="right"> 41196372 </td> <td> T </td> <td> C </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs189382442,rs189382442 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196402 </td> <td align="right"> 41196403 </td> <td> A </td> <td> G </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs182218567,rs182218567 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196407 </td> <td align="right"> 41196408 </td> <td> G </td> <td> A </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs12516,rs12516 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196581 </td> <td align="right"> 41196582 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> rs111791349,rs111791349 </td> <td> SNP </td> <td align="right"> 1092 </td> </tr>
   </table>
One can add more columns to the SELECT statement corresponding to INFO fields of interest as desired.

### Sample Data
Show variants for a particular sample within BRCA1:

```
-- Retrieve sample-level information for BRCA1 variants.
SELECT
  reference_name,
  start,
  `end`,
  reference_bases,
  ARRAY_TO_STRING(v.alternate_bases, ',') AS alts,
  quality,
  ARRAY_TO_STRING(v.filter, ',') AS filters,
  vt,
  ARRAY_TO_STRING(v.names, ',') AS names,
  call.call_set_name,
  call.phaseset,
  (SELECT STRING_AGG(CAST(gt AS STRING)) from UNNEST(call.genotype) gt) AS genotype,
  call.ds,
  (SELECT STRING_AGG(CAST(lh AS STRING)) from UNNEST(call.genotype_likelihood) lh) AS likelihoods
FROM
  `genomics-public-data.1000_genomes.variants` v, v.call call
WHERE
  reference_name IN ('17', 'chr17')
  AND start BETWEEN 41196311 AND 41277499 # per GRCh37
  AND call_set_name = 'HG00100'
ORDER BY
  start,
  alts
```
Number of rows returned by this query: 879.

Examing the first few rows, we see:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:27 2016 -->
<table border=1>
<tr> <th> reference_name </th> <th> start </th> <th> end </th> <th> reference_bases </th> <th> alts </th> <th> quality </th> <th> filters </th> <th> vt </th> <th> names </th> <th> call_set_name </th> <th> phaseset </th> <th> genotype </th> <th> ds </th> <th> likelihoods </th>  </tr>
  <tr> <td> 17 </td> <td align="right"> 41196362 </td> <td align="right"> 41196363 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs8176320,rs8176320 </td> <td> HG00100 </td> <td> * </td> <td> 0,0 </td> <td align="right"> 0.00 </td> <td> -0.03,-1.19,-5 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196367 </td> <td align="right"> 41196368 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs184237074,rs184237074 </td> <td> HG00100 </td> <td> * </td> <td> 0,0 </td> <td align="right"> 0.00 </td> <td> -0.02,-1.35,-5 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196371 </td> <td align="right"> 41196372 </td> <td> T </td> <td> C </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs189382442,rs189382442 </td> <td> HG00100 </td> <td> * </td> <td> 0,0 </td> <td align="right"> 0.00 </td> <td> -0.01,-1.48,-5 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196402 </td> <td align="right"> 41196403 </td> <td> A </td> <td> G </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs182218567,rs182218567 </td> <td> HG00100 </td> <td> * </td> <td> 0,0 </td> <td align="right"> 0.00 </td> <td> -0.03,-1.16,-5 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196407 </td> <td align="right"> 41196408 </td> <td> G </td> <td> A </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs12516,rs12516 </td> <td> HG00100 </td> <td> * </td> <td> 1,0 </td> <td align="right"> 1.00 </td> <td> -5,-0,-2.53 </td> </tr>
  <tr> <td> 17 </td> <td align="right"> 41196581 </td> <td align="right"> 41196582 </td> <td> C </td> <td> T </td> <td align="right"> 100.00 </td> <td> PASS </td> <td> SNP </td> <td> rs111791349,rs111791349 </td> <td> HG00100 </td> <td> * </td> <td> 0,0 </td> <td align="right"> 0.00 </td> <td> -0.18,-0.46,-2.43 </td> </tr>
   </table>
Note that this is equivalent to the [vcf-query](http://vcftools.sourceforge.net/perl_module.html#vcf-query) command
```
vcf-query ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz 17:41196312-41277500 -c HG00100
```

### Exploring shared variation
Lastly, let us get an overview of how much variation is shared across the samples.

```
-- Count the number of variants shared by none, shared by one sample, two samples, etc...
SELECT
  num_samples_with_variant,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alternate_bases[ORDINAL(1)] AS alt,  -- 1000 Genomes is biallelic.
    (SELECT COUNTIF(EXISTS(SELECT gt
                          FROM UNNEST(call.genotype) gt
                          WHERE gt >= 1)) FROM v.call) AS num_samples_with_variant
  FROM
    `genomics-public-data.1000_genomes.variants` v
  WHERE
    reference_name NOT IN ("X", "Y", "MT"))
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant
```
Number of rows returned by this query: 1093.

Examing the first few rows, we see that a substantial number of variants are shared by **none** of the samples but a larger number of the variants are shared by only one sample:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:30 2016 -->
<table border=1>
<tr> <th> num_samples_with_variant </th> <th> num_variants_shared_by_this_many_samples </th>  </tr>
  <tr> <td align="right">   0 </td> <td align="right"> 154741 </td> </tr>
  <tr> <td align="right">   1 </td> <td align="right"> 7966985 </td> </tr>
  <tr> <td align="right">   2 </td> <td align="right"> 4070129 </td> </tr>
  <tr> <td align="right">   3 </td> <td align="right"> 2538218 </td> </tr>
  <tr> <td align="right">   4 </td> <td align="right"> 1776034 </td> </tr>
  <tr> <td align="right">   5 </td> <td align="right"> 1327409 </td> </tr>
   </table>
Looking at the last few rows in the result, we see that some variants are shared by all samples:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:30 2016 -->
<table border=1>
<tr> <th> num_samples_with_variant </th> <th> num_variants_shared_by_this_many_samples </th>  </tr>
  <tr> <td align="right"> 1087 </td> <td align="right"> 16600 </td> </tr>
  <tr> <td align="right"> 1088 </td> <td align="right"> 18551 </td> </tr>
  <tr> <td align="right"> 1089 </td> <td align="right"> 22949 </td> </tr>
  <tr> <td align="right"> 1090 </td> <td align="right"> 28745 </td> </tr>
  <tr> <td align="right"> 1091 </td> <td align="right"> 40019 </td> </tr>
  <tr> <td align="right"> 1092 </td> <td align="right"> 119373 </td> </tr>
   </table>
And visually:
<img src="figure/shared Variants-1.png" title="plot of chunk shared Variants" alt="plot of chunk shared Variants" style="display: block; margin: auto;" />
At the left edge of the plot we see the data point for the number of variants for which all samples match the reference (X=0).  At the right edge of the plot we see the number of variants for which all samples do _not_ match the reference (X=1,092).  In between we see the counts of variants shared by X samples.

Now let us drill down by super population and common versus rare variants:

```
-- We'd like to see how the members of each super population share variation.
--
-- Let's generate a table where the records indicate:
--
-- For the variants that appear in a given super-population:
--  how many variants are singletons (not shared)?
--  how many variants are shared by exactly 2 individuals?
--  how many variants are shared by exactly 3 individuals?
--  etc ...
--  how many variants are shared by all members of the super population?
--
-- The variants and counts are further partitioned by whether the variant is common or rare.
WITH
  population_counts AS (
  SELECT
    super_population,
    COUNT(population) AS super_population_count
  FROM
    `genomics-public-data.1000_genomes.sample_info`
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    super_population),
  --
  autosome_calls AS (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alternate_bases[ORDINAL(1)] AS alt,  -- 1000 Genomes is biallelic.
    vt,
    af IS NOT NULL
    AND af >= 0.05 AS is_common_variant,
    call.call_set_name,
    super_population
  FROM
    `genomics-public-data.1000_genomes.variants` AS v, v.call AS call
  JOIN
    `genomics-public-data.1000_genomes.sample_info` AS p
  ON
    call.call_set_name = p.sample
  WHERE
    reference_name NOT IN ("X", "Y", "MT")
    AND EXISTS (SELECT gt FROM UNNEST(call.genotype) gt WHERE gt > 0)),
  --
  super_population_autosome_variants AS (
  SELECT
    reference_name,
    start,
    `end`,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant,
    COUNT(call_set_name) AS num_samples
  FROM
    autosome_calls
  GROUP BY
    reference_name,
    start,
    `end`,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant )
  --
  --
SELECT
  p.super_population AS super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  num_samples / super_population_count AS percent_samples,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM
  super_population_autosome_variants AS v
JOIN population_counts AS p
ON
  v.super_population = p.super_population
GROUP BY
  super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  percent_samples
ORDER BY
  num_samples,
  super_population,
  is_common_variant
```
Number of rows returned by this query: 1439.


First few rows:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:35 2016 -->
<table border=1>
<tr> <th> super_population </th> <th> super_population_count </th> <th> is_common_variant </th> <th> num_samples </th> <th> percent_samples </th> <th> num_variants_shared_by_this_many_samples </th>  </tr>
  <tr> <td> AFR </td> <td align="right"> 246 </td> <td> FALSE </td> <td align="right">   1 </td> <td align="right"> 0.00 </td> <td align="right"> 3850133 </td> </tr>
  <tr> <td> AFR </td> <td align="right"> 246 </td> <td> TRUE </td> <td align="right">   1 </td> <td align="right"> 0.00 </td> <td align="right"> 43369 </td> </tr>
  <tr> <td> AMR </td> <td align="right"> 181 </td> <td> FALSE </td> <td align="right">   1 </td> <td align="right"> 0.01 </td> <td align="right"> 5307115 </td> </tr>
  <tr> <td> AMR </td> <td align="right"> 181 </td> <td> TRUE </td> <td align="right">   1 </td> <td align="right"> 0.01 </td> <td align="right"> 9233 </td> </tr>
  <tr> <td> EAS </td> <td align="right"> 286 </td> <td> FALSE </td> <td align="right">   1 </td> <td align="right"> 0.00 </td> <td align="right"> 2877481 </td> </tr>
  <tr> <td> EAS </td> <td align="right"> 286 </td> <td> TRUE </td> <td align="right">   1 </td> <td align="right"> 0.00 </td> <td align="right"> 162776 </td> </tr>
   </table>
Last few rows:
<!-- html table generated in R 3.2.3 by xtable 1.8-2 package -->
<!-- Fri Dec  2 16:55:35 2016 -->
<table border=1>
<tr> <th> super_population </th> <th> super_population_count </th> <th> is_common_variant </th> <th> num_samples </th> <th> percent_samples </th> <th> num_variants_shared_by_this_many_samples </th>  </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 374 </td> <td align="right"> 0.99 </td> <td align="right"> 29660 </td> </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 375 </td> <td align="right"> 0.99 </td> <td align="right"> 32821 </td> </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 376 </td> <td align="right"> 0.99 </td> <td align="right"> 37886 </td> </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 377 </td> <td align="right"> 0.99 </td> <td align="right"> 42649 </td> </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 378 </td> <td align="right"> 1.00 </td> <td align="right"> 57257 </td> </tr>
  <tr> <td> EUR </td> <td align="right"> 379 </td> <td> TRUE </td> <td align="right"> 379 </td> <td align="right"> 1.00 </td> <td align="right"> 320149 </td> </tr>
   </table>

<img src="figure/shared variants by pop-1.png" title="plot of chunk shared variants by pop" alt="plot of chunk shared variants by pop" style="display: block; margin: auto;" />
The plot is interesting but a little too busy.  Let us break it down into
separate plots for common and rare variants.

First, common variants:
<img src="figure/shared common variants by pop-1.png" title="plot of chunk shared common variants by pop" alt="plot of chunk shared common variants by pop" style="display: block; margin: auto;" />
There seems to be some interesting shape to this plot, but the sample counts are a little misleading since the number of samples within each super population is not the same.  Let us normalize by total number of samples in each super population group.
<img src="figure/shared common variants by percent pop-1.png" title="plot of chunk shared common variants by percent pop" alt="plot of chunk shared common variants by percent pop" style="display: block; margin: auto;" />
Its interesting to see that the Asian superpopulation has both the most variants for which all samples match the reference and also the most variants for which all samples differ from the reference.

And now for rare variants:
<img src="figure/shared rare variants by pop-1.png" title="plot of chunk shared rare variants by pop" alt="plot of chunk shared rare variants by pop" style="display: block; margin: auto;" />
Again, normalizing by population size:
<img src="figure/shared rare variants by percent pop-1.png" title="plot of chunk shared rare variants by percent pop" alt="plot of chunk shared rare variants by percent pop" style="display: block; margin: auto;" />

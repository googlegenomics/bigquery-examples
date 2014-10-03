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
# Get the proportion of variants that have been reported in the dbSNP database
# version 132 , by chromosome, in the dataset.
SELECT
  reference_name,
  num_dbsnp_variants,
  num_variants,
  num_dbsnp_variants / num_variants frequency
FROM (
  SELECT
    reference_name,
    COUNT(1) AS num_variants,
    SUM(num_dbsnp_ids > 0) AS num_dbsnp_variants,
  FROM (
    SELECT
      reference_name,
      COUNT(names) WITHIN RECORD AS num_dbsnp_ids
    FROM
      [genomics-public-data:1000_genomes.variants]
      )
  GROUP BY
    reference_name
    )
ORDER BY
  num_variants DESC
```

We see the tabular results:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:18:53 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> num_dbsnp_variants </TH> <TH> num_variants </TH> <TH> frequency </TH>  </TR>
  <TR> <TD> 2 </TD> <TD align="right"> 3301885 </TD> <TD align="right"> 3307592 </TD> <TD align="right"> 0.998275 </TD> </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 3001739 </TD> <TD align="right"> 3007196 </TD> <TD align="right"> 0.998185 </TD> </TR>
  <TR> <TD> 3 </TD> <TD align="right"> 2758667 </TD> <TD align="right"> 2763454 </TD> <TD align="right"> 0.998268 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 2731973 </TD> <TD align="right"> 2736765 </TD> <TD align="right"> 0.998249 </TD> </TR>
  <TR> <TD> 5 </TD> <TD align="right"> 2525874 </TD> <TD align="right"> 2530217 </TD> <TD align="right"> 0.998284 </TD> </TR>
  <TR> <TD> 6 </TD> <TD align="right"> 2420027 </TD> <TD align="right"> 2424425 </TD> <TD align="right"> 0.998186 </TD> </TR>
  <TR> <TD> 7 </TD> <TD align="right"> 2211317 </TD> <TD align="right"> 2215231 </TD> <TD align="right"> 0.998233 </TD> </TR>
  <TR> <TD> 8 </TD> <TD align="right"> 2180311 </TD> <TD align="right"> 2183839 </TD> <TD align="right"> 0.998384 </TD> </TR>
  <TR> <TD> 11 </TD> <TD align="right"> 1891627 </TD> <TD align="right"> 1894908 </TD> <TD align="right"> 0.998269 </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 1879337 </TD> <TD align="right"> 1882663 </TD> <TD align="right"> 0.998233 </TD> </TR>
  <TR> <TD> 12 </TD> <TD align="right"> 1824513 </TD> <TD align="right"> 1828006 </TD> <TD align="right"> 0.998089 </TD> </TR>
  <TR> <TD> 9 </TD> <TD align="right"> 1649563 </TD> <TD align="right"> 1652388 </TD> <TD align="right"> 0.998290 </TD> </TR>
  <TR> <TD> X </TD> <TD align="right"> 1482078 </TD> <TD align="right"> 1487477 </TD> <TD align="right"> 0.996370 </TD> </TR>
  <TR> <TD> 13 </TD> <TD align="right"> 1370342 </TD> <TD align="right"> 1373000 </TD> <TD align="right"> 0.998064 </TD> </TR>
  <TR> <TD> 14 </TD> <TD align="right"> 1255966 </TD> <TD align="right"> 1258254 </TD> <TD align="right"> 0.998182 </TD> </TR>
  <TR> <TD> 16 </TD> <TD align="right"> 1208679 </TD> <TD align="right"> 1210619 </TD> <TD align="right"> 0.998398 </TD> </TR>
  <TR> <TD> 15 </TD> <TD align="right"> 1128457 </TD> <TD align="right"> 1130554 </TD> <TD align="right"> 0.998145 </TD> </TR>
  <TR> <TD> 18 </TD> <TD align="right"> 1086823 </TD> <TD align="right"> 1088820 </TD> <TD align="right"> 0.998166 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 1044658 </TD> <TD align="right"> 1046733 </TD> <TD align="right"> 0.998018 </TD> </TR>
  <TR> <TD> 20 </TD> <TD align="right">  853680 </TD> <TD align="right">  855166 </TD> <TD align="right"> 0.998262 </TD> </TR>
  <TR> <TD> 19 </TD> <TD align="right">  814343 </TD> <TD align="right">  816115 </TD> <TD align="right"> 0.997829 </TD> </TR>
  <TR> <TD> 21 </TD> <TD align="right">  517920 </TD> <TD align="right">  518965 </TD> <TD align="right"> 0.997986 </TD> </TR>
  <TR> <TD> 22 </TD> <TD align="right">  493717 </TD> <TD align="right">  494328 </TD> <TD align="right"> 0.998764 </TD> </TR>
  <TR> <TD> Y </TD> <TD align="right">    3403 </TD> <TD align="right">   18728 </TD> <TD align="right"> 0.181707 </TD> </TR>
  <TR> <TD> MT </TD> <TD align="right">     585 </TD> <TD align="right">    2834 </TD> <TD align="right"> 0.206422 </TD> </TR>
   </TABLE>

And visually:
<img src="figure/dbSNP Variants.png" title="plot of chunk dbSNP Variants" alt="plot of chunk dbSNP Variants" style="display: block; margin: auto;" />

### Variant Metadata
The 1000 Genomes variant data is stored in the [variants](https://bigquery.cloud.google.com/table/coherent-fx-462:1000_genomes.variants?pli=1) table.  Every record in the variants table maps to a single site (line) in the [VCF](http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41) file.  See the [schema](https://bigquery.cloud.google.com/table/coherent-fx-462:1000_genomes.variants?pli=1) for more detail.

Show variants within BRCA1:

```
# Get variant level metadata for variants within BRCA1.
SELECT
  reference_name,
  start,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
  AND 41277499
ORDER BY
  start
```
Number of rows returned by this query: 879.

Examing the first few rows, we see:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:18:57 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> names </TH> <TH> ref </TH> <TH> alt </TH> <TH> quality </TH> <TH> filters </TH> <TH> vt </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> rs8176320,rs8176320 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196367 </TD> <TD> rs184237074,rs184237074 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196371 </TD> <TD> rs189382442,rs189382442 </TD> <TD> T </TD> <TD> C </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196402 </TD> <TD> rs182218567,rs182218567 </TD> <TD> A </TD> <TD> G </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196407 </TD> <TD> rs12516,rs12516 </TD> <TD> G </TD> <TD> A </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196581 </TD> <TD> rs111791349,rs111791349 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> </TR>
   </TABLE>
One can add more columns to the SELECT statement corresponding to INFO fields of interest as desired.

### Sample Data
Show variants for a particular sample within BRCA1:

```
# Get sample level data for variants within BRCA1.
SELECT
  reference_name,
  start,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  quality,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  vt,
  call.call_set_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1,
    call.genotype) WITHIN call AS first_allele,
  NTH(2,
    call.genotype) WITHIN call AS second_allele,
  call.ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start BETWEEN 41196311
      AND 41277499
HAVING
  sample_id = 'HG00100'
ORDER BY
  start
```
Number of rows returned by this query: 879.

Examing the first few rows, we see:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:19:02 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> names </TH> <TH> ref </TH> <TH> alt </TH> <TH> quality </TH> <TH> filters </TH> <TH> vt </TH> <TH> sample_id </TH> <TH> phaseset </TH> <TH> first_allele </TH> <TH> second_allele </TH> <TH> call_ds </TH> <TH> likelihoods </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> rs8176320,rs8176320 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD> -0.03,-1.19,-5 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196367 </TD> <TD> rs184237074,rs184237074 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD> -0.02,-1.35,-5 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196371 </TD> <TD> rs189382442,rs189382442 </TD> <TD> T </TD> <TD> C </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD> -0.01,-1.48,-5 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196402 </TD> <TD> rs182218567,rs182218567 </TD> <TD> A </TD> <TD> G </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD> -0.03,-1.16,-5 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196407 </TD> <TD> rs12516,rs12516 </TD> <TD> G </TD> <TD> A </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   1 </TD> <TD align="right">   0 </TD> <TD align="right"> 1.00 </TD> <TD> -5,0,-2.53 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196581 </TD> <TD> rs111791349,rs111791349 </TD> <TD> C </TD> <TD> T </TD> <TD align="right"> 100.00 </TD> <TD> PASS </TD> <TD> SNP </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD> -0.18,-0.46,-2.43 </TD> </TR>
   </TABLE>
Note that this is equivalent to the [vcf-query](http://vcftools.sourceforge.net/perl_module.html#vcf-query) command
```
vcf-query ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz 17:41196312-41277500 -c HG00100
```

### Exploring shared variation
Lastly, let us get an overview of how much variation is shared across the samples.

```
# Count the number of variants shared by none, shared by one sample, two samples, etc...
SELECT
  num_samples_with_variant,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM (
  SELECT
    SUM(first_allele > 0
      OR (second_allele IS NOT NULL
        AND second_allele > 0)) AS num_samples_with_variant
  FROM(
    SELECT
      reference_name,
      start,
      END,
      reference_bases,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      NTH(1,
        call.genotype) WITHIN call AS first_allele,
      NTH(2,
        call.genotype) WITHIN call AS second_allele,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      reference_name NOT IN ("X", "Y", "MT")
    )
    GROUP EACH BY
    reference_name,
    start,
    END,
    reference_bases,
    alt
    )
GROUP BY
  num_samples_with_variant
ORDER BY
  num_samples_with_variant
```
Number of rows returned by this query: 1093.

Examing the first few rows, we see that a substantial number of variants are shared by **none** of the samples but a larger number of the variants are shared by only one sample:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:19:07 2014 -->
<TABLE border=1>
<TR> <TH> num_samples_with_variant </TH> <TH> num_variants_shared_by_this_many_samples </TH>  </TR>
  <TR> <TD align="right">   0 </TD> <TD align="right"> 154741 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD align="right"> 7966985 </TD> </TR>
  <TR> <TD align="right">   2 </TD> <TD align="right"> 4070129 </TD> </TR>
  <TR> <TD align="right">   3 </TD> <TD align="right"> 2538218 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD align="right"> 1776034 </TD> </TR>
  <TR> <TD align="right">   5 </TD> <TD align="right"> 1327409 </TD> </TR>
   </TABLE>
Looking at the last few rows in the result, we see that some variants are shared by all samples:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:19:07 2014 -->
<TABLE border=1>
<TR> <TH> num_samples_with_variant </TH> <TH> num_variants_shared_by_this_many_samples </TH>  </TR>
  <TR> <TD align="right"> 1087 </TD> <TD align="right"> 16600 </TD> </TR>
  <TR> <TD align="right"> 1088 </TD> <TD align="right"> 18551 </TD> </TR>
  <TR> <TD align="right"> 1089 </TD> <TD align="right"> 22949 </TD> </TR>
  <TR> <TD align="right"> 1090 </TD> <TD align="right"> 28745 </TD> </TR>
  <TR> <TD align="right"> 1091 </TD> <TD align="right"> 40019 </TD> </TR>
  <TR> <TD align="right"> 1092 </TD> <TD align="right"> 119373 </TD> </TR>
   </TABLE>
And visually:
<img src="figure/shared Variants.png" title="plot of chunk shared Variants" alt="plot of chunk shared Variants" style="display: block; margin: auto;" />
At the left edge of the plot we see the data point for the number of variants for which all samples match the reference (X=0).  At the right edge of the plot we see the number of variants for which all samples do _not_ match the reference (X=1,092).  In between we see the counts of variants shared by X samples.

Now let us drill down by super population and common versus rare variants:

```
# COUNT the number of variants shared BY none, shared BY one sample, two samples, etc...
# further grouped by super population and common versus rare variants.
SELECT
  pops.super_population AS super_population,
  super_population_count,
  is_common_variant,
  num_samples,
  num_samples / super_population_count
  AS percent_samples,
  COUNT(1) AS num_variants_shared_by_this_many_samples
FROM
  (
  SELECT
    reference_name,
    start,
    end,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant,
    SUM(has_variant) AS num_samples
  FROM (
    SELECT
      reference_name,
      start,
      end,
      reference_bases,
      alt,
      vt,
      super_population,
      is_common_variant,
      IF(first_allele > 0
        OR (second_allele IS NOT NULL
            AND second_allele > 0),
        1,
        0) AS has_variant
    FROM (
        FLATTEN((
          SELECT
            reference_name,
            start,
            end,
            reference_bases,
            GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
            vt,
            (af IS NOT NULL AND af >= 0.05) AS is_common_variant,
            call.call_set_name AS sample_id,
            NTH(1,
              call.genotype) WITHIN call AS first_allele,
            NTH(2,
              call.genotype) WITHIN call AS second_allele,
          FROM
            [genomics-public-data:1000_genomes.variants]
          WHERE
            reference_name NOT IN ("X", "Y", "MT")),
          call)) AS samples
    JOIN
      [genomics-public-data:1000_genomes.sample_info] p
    ON
      samples.sample_id = p.sample)
    GROUP EACH BY
    reference_name,
    start,
    end,
    reference_bases,
    alt,
    vt,
    super_population,
    is_common_variant) AS vars
JOIN (
  SELECT
    super_population,
    COUNT(population) AS super_population_count,
  FROM
    [genomics-public-data:1000_genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    super_population) AS pops
ON
  vars.super_population = pops.super_population
GROUP EACH BY
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
Number of rows returned by this query: 1447.


First few rows:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:19:12 2014 -->
<TABLE border=1>
<TR> <TH> super_population </TH> <TH> super_population_count </TH> <TH> is_common_variant </TH> <TH> num_samples </TH> <TH> percent_samples </TH> <TH> num_variants_shared_by_this_many_samples </TH>  </TR>
  <TR> <TD> AFR </TD> <TD align="right"> 246 </TD> <TD> FALSE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 12386569 </TD> </TR>
  <TR> <TD> AFR </TD> <TD align="right"> 246 </TD> <TD> TRUE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 30575 </TD> </TR>
  <TR> <TD> AMR </TD> <TD align="right"> 181 </TD> <TD> FALSE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 18234923 </TD> </TR>
  <TR> <TD> AMR </TD> <TD align="right"> 181 </TD> <TD> TRUE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 8031 </TD> </TR>
  <TR> <TD> EAS </TD> <TD align="right"> 286 </TD> <TD> FALSE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 23042472 </TD> </TR>
  <TR> <TD> EAS </TD> <TD align="right"> 286 </TD> <TD> TRUE </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 578585 </TD> </TR>
   </TABLE>
Last few rows:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Thu Oct  2 21:19:12 2014 -->
<TABLE border=1>
<TR> <TH> super_population </TH> <TH> super_population_count </TH> <TH> is_common_variant </TH> <TH> num_samples </TH> <TH> percent_samples </TH> <TH> num_variants_shared_by_this_many_samples </TH>  </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 374 </TD> <TD align="right"> 0.99 </TD> <TD align="right"> 29660 </TD> </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 375 </TD> <TD align="right"> 0.99 </TD> <TD align="right"> 32821 </TD> </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 376 </TD> <TD align="right"> 0.99 </TD> <TD align="right"> 37886 </TD> </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 377 </TD> <TD align="right"> 0.99 </TD> <TD align="right"> 42649 </TD> </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 378 </TD> <TD align="right"> 1.00 </TD> <TD align="right"> 57257 </TD> </TR>
  <TR> <TD> EUR </TD> <TD align="right"> 379 </TD> <TD> TRUE </TD> <TD align="right"> 379 </TD> <TD align="right"> 1.00 </TD> <TD align="right"> 320149 </TD> </TR>
   </TABLE>

<img src="figure/shared variants by pop.png" title="plot of chunk shared variants by pop" alt="plot of chunk shared variants by pop" style="display: block; margin: auto;" />
The plot is interesting but a little too busy.  Let us break it down into
separate plots for common and rare variants.

First, common variants:
<img src="figure/shared common variants by pop.png" title="plot of chunk shared common variants by pop" alt="plot of chunk shared common variants by pop" style="display: block; margin: auto;" />
There seems to be some interesting shape to this plot, but the sample counts are a little misleading since the number of samples within each super population is not the same.  Let us normalize by total number of samples in each super population group.
<img src="figure/shared common variants by percent pop.png" title="plot of chunk shared common variants by percent pop" alt="plot of chunk shared common variants by percent pop" style="display: block; margin: auto;" />
Its interesting to see that the Asian superpopulation has both the most variants for which all samples match the reference and also the most variants for which all samples differ from the reference.

And now for rare variants:
<img src="figure/shared rare variants by pop.png" title="plot of chunk shared rare variants by pop" alt="plot of chunk shared rare variants by pop" style="display: block; margin: auto;" />
Again, normalizing by population size:
<img src="figure/shared rare variants by percent pop.png" title="plot of chunk shared rare variants by percent pop" alt="plot of chunk shared rare variants by percent pop" style="display: block; margin: auto;" />

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

Reproducing 1,000 Genomes allele frequencies for variants in BRCA1
========================================================

The following query computes the frequency of both the reference and alternate SNPs within BRCA1 for all samples within 1,000 Genomes.




```
# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset and also includes the pre-computed value from the dataset.
SELECT
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  SUM(ref_count)+SUM(alt_count) AS num_sample_alleles,
  SUM(ref_count) AS ref_cnt,
  SUM(alt_count) AS alt_cnt,
  SUM(ref_count)/(SUM(ref_count)+SUM(alt_count)) AS ref_freq,
  SUM(alt_count)/(SUM(ref_count)+SUM(alt_count)) AS alt_freq,
  alt_freq_from_1KG
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    alternate_bases,
    alt,
    SUM(INTEGER(0 = call.genotype)) WITHIN RECORD AS ref_count,
    SUM(INTEGER(alt = call.genotype)) WITHIN RECORD AS alt_count,
    alt_freq_from_1KG
  FROM
    FLATTEN(
      FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          POSITION(alternate_bases) AS alt,
          af AS alt_freq_from_1KG,
          call.call_set_name,
          call.genotype,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '17'
          AND start BETWEEN 41196311
          AND 41277499
          AND vt='SNP'
          ),
        call),
      alt))
GROUP BY
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  alt,
  alt_freq_from_1KG
ORDER BY
  reference_name,
  start,
  reference_bases,
  alt,
  alternate_bases
```
Number of rows returned by this query: 843.

Displaying the first few rows of our result:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Sun Oct 19 16:33:26 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> reference_bases </TH> <TH> alternate_bases </TH> <TH> num_sample_alleles </TH> <TH> ref_cnt </TH> <TH> alt_cnt </TH> <TH> ref_freq </TH> <TH> alt_freq </TH> <TH> alt_freq_from_1KG </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> C </TD> <TD> T </TD> <TD align="right">    2184 </TD> <TD align="right">    2173 </TD> <TD align="right">      11 </TD> <TD align="right"> 0.994963 </TD> <TD align="right"> 0.005037 </TD> <TD align="right"> 0.010000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196367 </TD> <TD> C </TD> <TD> T </TD> <TD align="right">    2184 </TD> <TD align="right">    2183 </TD> <TD align="right">       1 </TD> <TD align="right"> 0.999542 </TD> <TD align="right"> 0.000458 </TD> <TD align="right"> 0.000500 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196371 </TD> <TD> T </TD> <TD> C </TD> <TD align="right">    2184 </TD> <TD align="right">    2183 </TD> <TD align="right">       1 </TD> <TD align="right"> 0.999542 </TD> <TD align="right"> 0.000458 </TD> <TD align="right"> 0.000500 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196402 </TD> <TD> A </TD> <TD> G </TD> <TD align="right">    2184 </TD> <TD align="right">    2183 </TD> <TD align="right">       1 </TD> <TD align="right"> 0.999542 </TD> <TD align="right"> 0.000458 </TD> <TD align="right"> 0.000500 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196407 </TD> <TD> G </TD> <TD> A </TD> <TD align="right">    2184 </TD> <TD align="right">    1503 </TD> <TD align="right">     681 </TD> <TD align="right"> 0.688187 </TD> <TD align="right"> 0.311813 </TD> <TD align="right"> 0.310000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196581 </TD> <TD> C </TD> <TD> T </TD> <TD align="right">    2184 </TD> <TD align="right">    2173 </TD> <TD align="right">      11 </TD> <TD align="right"> 0.994963 </TD> <TD align="right"> 0.005037 </TD> <TD align="right"> 0.010000 </TD> </TR>
   </TABLE>

And do our results match the precomputed values resident in the AF INFO field?

```r
print(expect_equal(object=result$alt_freq,
                   expected=result$alt_freq_from_1KG,
                   tolerance=0.005,
                   scale=1))
```

```
## As expected: result$alt_freq equals result$alt_freq_from_1KG
```
We can see from the results that when the computed frequency values in column alt_freq are rounded, they exactly match the alternate allele frequencies as reported in the AF INFO field from the 1,000 Genomes VCF data.

Next, we compute those same alternate allele frequencies further broken down by super population groups.

```
# The following query computes the allelic frequency for BRCA1 variants in the
# 1,000 Genomes dataset further classified by ethnicity from the phenotypic data
# and also includes the pre-computed value from the dataset.
SELECT
  reference_name,
  start,
  super_population,
  reference_bases,
  alternate_bases,
  SUM(ref_count)+SUM(alt_count) AS num_sample_alleles,
  SUM(ref_count) AS sample_allele_ref_cnt,
  SUM(alt_count) AS sample_allele_alt_cnt,
  SUM(ref_count)/(SUM(ref_count)+SUM(alt_count)) AS ref_freq,
  SUM(alt_count)/(SUM(ref_count)+SUM(alt_count)) AS alt_freq,
  alt_freq_from_1KG
FROM (
  SELECT
    reference_name,
    start,
    super_population,
    reference_bases,
    alternate_bases,
    alt,
    SUM(INTEGER(0 = call.genotype)) WITHIN RECORD AS ref_count,
    SUM(INTEGER(alt = call.genotype)) WITHIN RECORD AS alt_count,
    CASE
    WHEN super_population =  'EAS'
    THEN  asn_af
    WHEN super_population=  'EUR'
    THEN eur_af
    WHEN super_population = 'AFR'
    THEN afr_af
    WHEN super_population = 'AMR'
    THEN amr_af
    END AS alt_freq_from_1KG
  FROM
    FLATTEN(FLATTEN((
        SELECT
          reference_name,
          start,
          reference_bases,
          alternate_bases,
          POSITION(alternate_bases) AS alt,
          call.call_set_name,
          call.genotype,
          afr_af,
          amr_af,
          asn_af,
          eur_af,
        FROM
          [genomics-public-data:1000_genomes.variants]
        WHERE
          reference_name = '17'
          AND start BETWEEN 41196311
          AND 41277499
          AND vt='SNP'
          ),
        call),
      alt) AS g
  JOIN
    [genomics-public-data:1000_genomes.sample_info] p
  ON
    g.call.call_set_name = p.sample)
GROUP BY
  reference_name,
  start,
  super_population,
  reference_bases,
  alternate_bases,
  alt_freq_from_1KG
ORDER BY
  reference_name,
  start,
  super_population
```
Number of rows returned by this query: 3372.

Displaying the first few rows of our result:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Sun Oct 19 16:33:37 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> super_population </TH> <TH> reference_bases </TH> <TH> alternate_bases </TH> <TH> num_sample_alleles </TH> <TH> sample_allele_ref_cnt </TH> <TH> sample_allele_alt_cnt </TH> <TH> ref_freq </TH> <TH> alt_freq </TH> <TH> alt_freq_from_1KG </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> AFR </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     492 </TD> <TD align="right">     492 </TD> <TD align="right">       0 </TD> <TD align="right"> 1.000000 </TD> <TD align="right"> 0.000000 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> AMR </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     362 </TD> <TD align="right">     360 </TD> <TD align="right">       2 </TD> <TD align="right"> 0.994475 </TD> <TD align="right"> 0.005525 </TD> <TD align="right"> 0.010000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> EAS </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     572 </TD> <TD align="right">     572 </TD> <TD align="right">       0 </TD> <TD align="right"> 1.000000 </TD> <TD align="right"> 0.000000 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196362 </TD> <TD> EUR </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     758 </TD> <TD align="right">     749 </TD> <TD align="right">       9 </TD> <TD align="right"> 0.988127 </TD> <TD align="right"> 0.011873 </TD> <TD align="right"> 0.010000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196367 </TD> <TD> AFR </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     492 </TD> <TD align="right">     492 </TD> <TD align="right">       0 </TD> <TD align="right"> 1.000000 </TD> <TD align="right"> 0.000000 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196367 </TD> <TD> AMR </TD> <TD> C </TD> <TD> T </TD> <TD align="right">     362 </TD> <TD align="right">     362 </TD> <TD align="right">       0 </TD> <TD align="right"> 1.000000 </TD> <TD align="right"> 0.000000 </TD> <TD align="right">  </TD> </TR>
   </TABLE>

And do our results match the precomputed values resident in the superpopulation-specific AF INFO fields?

```r
# coerce NAs to be zero
result$alt_freq_from_1KG[is.na(result$alt_freq_from_1KG)] <- 0.0
print(expect_equal(object=result$alt_freq,
                   expected=result$alt_freq_from_1KG,
                   tolerance=0.005,
                   scale=1))
```

```
## As expected: result$alt_freq equals result$alt_freq_from_1KG
```
We can see from the results that when the computed frequency values in column alt_freq are rounded, they exactly match the alternate allele frequencies as reported in the AFR_AF, ASN_AF, AMR_AF, EUR_AF INFO fields from the 1,000 Genomes VCF data.

Moving onto other results regarding rates of variation across populations:

```
# Count the variation for each sample including phenotypic traits
SELECT
  samples.call.call_set_name AS sample_id,
  gender,
  population,
  super_population,
  COUNT(samples.call.call_set_name) AS num_variants_for_sample,
  SUM(samples.af >= 0.05) AS common_variant,
  SUM(samples.af < 0.05 AND samples.af > 0.005) AS middle_variant,
  SUM(samples.af <= 0.005 AND samples.af > 0.001) AS rare_variant,
  SUM(samples.af <= 0.001) AS very_rare_variant,
FROM
  FLATTEN((
    SELECT
      af,
      vt,
      call.call_set_name,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      vt = 'SNP'
    OMIT call IF EVERY(call.genotype <= 0)),
    call) AS samples
JOIN
  [genomics-public-data:1000_genomes.sample_info] p
ON
  samples.call.call_set_name = p.sample
GROUP BY
  sample_id,
  gender,
  population,
  super_population
ORDER BY
  sample_id
```
Number of rows returned by this query: 1092.

Displaying the first few rows of our result:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Sun Oct 19 16:33:44 2014 -->
<TABLE border=1>
<TR> <TH> sample_id </TH> <TH> gender </TH> <TH> population </TH> <TH> super_population </TH> <TH> num_variants_for_sample </TH> <TH> common_variant </TH> <TH> middle_variant </TH> <TH> rare_variant </TH> <TH> very_rare_variant </TH>  </TR>
  <TR> <TD> HG00096 </TD> <TD> male </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3503172 </TD> <TD align="right"> 3339817 </TD> <TD align="right">  128924 </TD> <TD align="right">   24135 </TD> <TD align="right">   10296 </TD> </TR>
  <TR> <TD> HG00097 </TD> <TD> female </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3510561 </TD> <TD align="right"> 3319102 </TD> <TD align="right">  152639 </TD> <TD align="right">   27066 </TD> <TD align="right">   11754 </TD> </TR>
  <TR> <TD> HG00099 </TD> <TD> female </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3513503 </TD> <TD align="right"> 3321988 </TD> <TD align="right">  150869 </TD> <TD align="right">   27843 </TD> <TD align="right">   12803 </TD> </TR>
  <TR> <TD> HG00100 </TD> <TD> female </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3525879 </TD> <TD align="right"> 3364308 </TD> <TD align="right">  130449 </TD> <TD align="right">   24407 </TD> <TD align="right">    6715 </TD> </TR>
  <TR> <TD> HG00101 </TD> <TD> male </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3491663 </TD> <TD align="right"> 3312663 </TD> <TD align="right">  141650 </TD> <TD align="right">   26278 </TD> <TD align="right">   11072 </TD> </TR>
  <TR> <TD> HG00102 </TD> <TD> female </TD> <TD> GBR </TD> <TD> EUR </TD> <TD align="right"> 3510479 </TD> <TD align="right"> 3333491 </TD> <TD align="right">  140417 </TD> <TD align="right">   25801 </TD> <TD align="right">   10770 </TD> </TR>
   </TABLE>

Some data visualization will help us to see more clearly the pattern resident within the results:
<img src="figure/maf.png" title="plot of chunk maf" alt="plot of chunk maf" style="display: block; margin: auto;" />
and now its clear to see that the ethnicities within the African super population have a much higher rate of mutation compared to the other ethnicities for the common variants.

This difference is even more notable when looking at all variants:
<img src="figure/all variants.png" title="plot of chunk all variants" alt="plot of chunk all variants" style="display: block; margin: auto;" />

Now lets examine the rate of variation across genders:
<img src="figure/common variants by gender.png" title="plot of chunk common variants by gender" alt="plot of chunk common variants by gender" style="display: block; margin: auto;" />
We see a noticieable difference, BUT this query included variants within chromosome X.  Updating the query to ignore sex chromosomes:

```
# Count the variation for each sample including phenotypic traits but excluding
# sex chromosomes.
SELECT
  samples.call.call_set_name AS sample_id,
  gender,
  population,
  super_population,
  COUNT(samples.call.call_set_name) AS num_variants_for_sample,
  SUM(samples.af >= 0.05) AS common_variant,
  SUM(samples.af < 0.05 AND samples.af > 0.005) AS middle_variant,
  SUM(samples.af <= 0.005 AND samples.af > 0.001) AS rare_variant,
  SUM(samples.af <= 0.001) AS very_rare_variant,
FROM
  FLATTEN((
    SELECT
      af,
      vt,
      call.call_set_name,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      vt = 'SNP'
      AND reference_name != 'X'
      AND reference_name != 'Y'
    OMIT call IF EVERY(call.genotype <= 0)),
    call) AS samples
JOIN
  [genomics-public-data:1000_genomes.sample_info] p
ON
  samples.call.call_set_name = p.sample
GROUP BY
  sample_id,
  gender,
  population,
  super_population
ORDER BY
  sample_id
```
We see that the genders are quite close in their rate of variation.
<img src="figure/viz maf no X.png" title="plot of chunk viz maf no X" alt="plot of chunk viz maf no X" style="display: block; margin: auto;" />

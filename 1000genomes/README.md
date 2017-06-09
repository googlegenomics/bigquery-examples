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
#standardSQL
--
-- Get the proportion of variants (per chromosome) in the dataset
-- that have been reported in the dbSNP database (version 132).
--
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

|reference_name | num_dbsnp_variants| num_variants| frequency|
|:--------------|------------------:|------------:|---------:|
|2              |            3301885|      3307592|  0.998275|
|1              |            3001739|      3007196|  0.998185|
|3              |            2758667|      2763454|  0.998268|
|4              |            2731973|      2736765|  0.998249|
|5              |            2525874|      2530217|  0.998284|
|6              |            2420027|      2424425|  0.998186|
|7              |            2211317|      2215231|  0.998233|
|8              |            2180311|      2183839|  0.998384|
|11             |            1891627|      1894908|  0.998269|
|10             |            1879337|      1882663|  0.998233|
|12             |            1824513|      1828006|  0.998089|
|9              |            1649563|      1652388|  0.998290|
|X              |            1482078|      1487477|  0.996370|
|13             |            1370342|      1373000|  0.998064|
|14             |            1255966|      1258254|  0.998182|
|16             |            1208679|      1210619|  0.998398|
|15             |            1128457|      1130554|  0.998145|
|18             |            1086823|      1088820|  0.998166|
|17             |            1044658|      1046733|  0.998018|
|20             |             853680|       855166|  0.998262|
|19             |             814343|       816115|  0.997829|
|21             |             517920|       518965|  0.997986|
|22             |             493717|       494328|  0.998764|
|Y              |               3403|        18728|  0.181707|
|MT             |                585|         2834|  0.206422|

And visually:
<img src="figure/dbSNP Variants-1.png" title="plot of chunk dbSNP Variants" alt="plot of chunk dbSNP Variants" style="display: block; margin: auto;" />

### Variant Metadata
The 1000 Genomes variant data is stored in the [variants](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.variants?pli=1) table.  Every record in the variants table maps to a single site (line) in the [VCF](http://www.1000genomes.org/wiki/Analysis/Variant%20Call%20Format/vcf-variant-call-format-version-41) file.  See the [schema](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.variants?pli=1) for more detail.

Show variants within BRCA1:

```
#standardSQL
--
-- Retrieve variant-level information for BRCA1 variants.
--
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

|reference_name |    start|      end|reference_bases |alts | quality|filter |names                   |vt  | num_samples|
|:--------------|--------:|--------:|:---------------|:----|-------:|:------|:-----------------------|:---|-----------:|
|17             | 41196362| 41196363|C               |T    |     100|PASS   |rs8176320,rs8176320     |SNP |        1092|
|17             | 41196367| 41196368|C               |T    |     100|PASS   |rs184237074,rs184237074 |SNP |        1092|
|17             | 41196371| 41196372|T               |C    |     100|PASS   |rs189382442,rs189382442 |SNP |        1092|
|17             | 41196402| 41196403|A               |G    |     100|PASS   |rs182218567,rs182218567 |SNP |        1092|
|17             | 41196407| 41196408|G               |A    |     100|PASS   |rs12516,rs12516         |SNP |        1092|
|17             | 41196581| 41196582|C               |T    |     100|PASS   |rs111791349,rs111791349 |SNP |        1092|
One can add more columns to the SELECT statement corresponding to INFO fields of interest as desired.

### Sample Data
Show variants for a particular sample within BRCA1:

```
#standardSQL
--
-- Retrieve sample-level information for BRCA1 variants.
--
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

|reference_name |    start|      end|reference_bases |alts | quality|filters |vt  |names                   |call_set_name |phaseset |genotype | ds|likelihoods       |
|:--------------|--------:|--------:|:---------------|:----|-------:|:-------|:---|:-----------------------|:-------------|:--------|:--------|--:|:-----------------|
|17             | 41196362| 41196363|C               |T    |     100|PASS    |SNP |rs8176320,rs8176320     |HG00100       |*        |0,0      |  0|-0.03,-1.19,-5    |
|17             | 41196367| 41196368|C               |T    |     100|PASS    |SNP |rs184237074,rs184237074 |HG00100       |*        |0,0      |  0|-0.02,-1.35,-5    |
|17             | 41196371| 41196372|T               |C    |     100|PASS    |SNP |rs189382442,rs189382442 |HG00100       |*        |0,0      |  0|-0.01,-1.48,-5    |
|17             | 41196402| 41196403|A               |G    |     100|PASS    |SNP |rs182218567,rs182218567 |HG00100       |*        |0,0      |  0|-0.03,-1.16,-5    |
|17             | 41196407| 41196408|G               |A    |     100|PASS    |SNP |rs12516,rs12516         |HG00100       |*        |1,0      |  1|-5,-0,-2.53       |
|17             | 41196581| 41196582|C               |T    |     100|PASS    |SNP |rs111791349,rs111791349 |HG00100       |*        |0,0      |  0|-0.18,-0.46,-2.43 |
Note that this is equivalent to the [vcf-query](http://vcftools.sourceforge.net/perl_module.html#vcf-query) command
```
vcf-query ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz 17:41196312-41277500 -c HG00100
```

### Exploring shared variation
Lastly, let us get an overview of how much variation is shared across the samples.

```
#standardSQL
--
-- Count the number of variants shared by none, shared by one sample, two samples, etc...
--
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

| num_samples_with_variant| num_variants_shared_by_this_many_samples|
|------------------------:|----------------------------------------:|
|                        0|                                   154741|
|                        1|                                  7966985|
|                        2|                                  4070129|
|                        3|                                  2538218|
|                        4|                                  1776034|
|                        5|                                  1327409|
Looking at the last few rows in the result, we see that some variants are shared by all samples:

|     | num_samples_with_variant| num_variants_shared_by_this_many_samples|
|:----|------------------------:|----------------------------------------:|
|1088 |                     1087|                                    16600|
|1089 |                     1088|                                    18551|
|1090 |                     1089|                                    22949|
|1091 |                     1090|                                    28745|
|1092 |                     1091|                                    40019|
|1093 |                     1092|                                   119373|
And visually:
<img src="figure/shared Variants-1.png" title="plot of chunk shared Variants" alt="plot of chunk shared Variants" style="display: block; margin: auto;" />
At the left edge of the plot we see the data point for the number of variants for which all samples match the reference (X=0).  At the right edge of the plot we see the number of variants for which all samples do _not_ match the reference (X=1,092).  In between we see the counts of variants shared by X samples.

Now let us drill down by super population and common versus rare variants:

```
#standardSQL
--
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
--
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

|super_population | super_population_count|is_common_variant | num_samples| percent_samples| num_variants_shared_by_this_many_samples|
|:----------------|----------------------:|:-----------------|-----------:|---------------:|----------------------------------------:|
|AFR              |                    246|FALSE             |           1|       0.0040650|                                  3850133|
|AFR              |                    246|TRUE              |           1|       0.0040650|                                    43369|
|AMR              |                    181|FALSE             |           1|       0.0055249|                                  5307115|
|AMR              |                    181|TRUE              |           1|       0.0055249|                                     9233|
|EAS              |                    286|FALSE             |           1|       0.0034965|                                  2877481|
|EAS              |                    286|TRUE              |           1|       0.0034965|                                   162776|
Last few rows:

|     |super_population | super_population_count|is_common_variant | num_samples| percent_samples| num_variants_shared_by_this_many_samples|
|:----|:----------------|----------------------:|:-----------------|-----------:|---------------:|----------------------------------------:|
|1434 |EUR              |                    379|TRUE              |         374|       0.9868074|                                    29660|
|1435 |EUR              |                    379|TRUE              |         375|       0.9894459|                                    32821|
|1436 |EUR              |                    379|TRUE              |         376|       0.9920844|                                    37886|
|1437 |EUR              |                    379|TRUE              |         377|       0.9947230|                                    42649|
|1438 |EUR              |                    379|TRUE              |         378|       0.9973615|                                    57257|
|1439 |EUR              |                    379|TRUE              |         379|       1.0000000|                                   320149|

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

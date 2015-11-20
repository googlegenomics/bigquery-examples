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

Comparing PGP variants data to that of 1,000 Genomes
========================================================

How does the structure and composition of the Complete Genomics PGP dataset vary from that of 1,000 Genomes, described in detail via the [1,000 Genomes data stories](../../../1000genomes/data-stories)?





Variant Level Data
------------------

First let us get an overview of how many variants we have in these datasets:

```
# Count the number of variants per chromosome.
SELECT
  reference_name,
  cnt,
  dataset
FROM (
  SELECT
    reference_name,
    COUNT(reference_name) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name
    ),
  (
  SELECT
    # Normalize the reference_name to match that found in 1,000 Genomes.
    IF(reference_name = 'chrM', 'MT', SUBSTR(reference_name, 4)) AS reference_name,
    COUNT(reference_name) AS cnt,
    'PGP' AS dataset
  FROM
    [google.com:biggene:pgp_20150205.genome_calls]
  # The source data was Complete Genomics which includes non-variant segments.
  OMIT RECORD IF EVERY(alternate_bases IS NULL)
  GROUP BY
    reference_name)
ORDER BY
  reference_name,
  dataset
```

We see the first few tabular results:
<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Thu Nov 19 17:22:11 2015 -->
<table border=1>
<tr> <th> reference_name </th> <th> cnt </th> <th> dataset </th>  </tr>
  <tr> <td> 1 </td> <td align="right"> 3007196 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 1 </td> <td align="right"> 2840932 </td> <td> PGP </td> </tr>
  <tr> <td> 10 </td> <td align="right"> 1882663 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 10 </td> <td align="right"> 1717853 </td> <td> PGP </td> </tr>
  <tr> <td> 11 </td> <td align="right"> 1894908 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 11 </td> <td align="right"> 1798453 </td> <td> PGP </td> </tr>
   </table>

<img src="figure/variant counts-1.png" title="plot of chunk variant counts" alt="plot of chunk variant counts" style="display: block; margin: auto;" />
We see that the two datasets have a similar number of variants on each chromosome.

Let's break this down further by variant type:

```
# Count the number of variants by variant type and chromosome.
SELECT
  reference_name,
  vt,
  cnt,
  dataset
FROM (
  SELECT
    # Normalize the reference_name to match that found in 1,000 Genomes.
    IF(reference_name = 'chrM', 'MT', SUBSTR(reference_name, 4)) AS reference_name,
    IF(ref_len = 1 AND alt_len = 1, "SNP", "INDEL") AS vt,
    COUNT(reference_name) AS cnt,
    'PGP' AS dataset
  FROM (
    SELECT
      reference_name,
      svtype,
      LENGTH(reference_bases) AS ref_len,
      MAX(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
    FROM
      [google.com:biggene:pgp_20150205.genome_calls]
    # The source data was Complete Genomics which includes non-variant segments.
    OMIT RECORD IF EVERY(alternate_bases IS NULL)
      )
  GROUP BY
    reference_name,
    vt
    ),
  (
  SELECT
    reference_name,
    IF(vt IS NULL, "not specified", vt) AS vt,
    COUNT(reference_name) AS cnt,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  GROUP BY
    reference_name,
    vt
    ),
ORDER BY
  reference_name,
  dataset,
  vt
```
Notice that PGP has no column indicating variant type, so it is inferred from the data.  The PGP
data was imported from Complete Genomics masterVar files which do not contain structural variants.

We see the first few tabular results:
<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Thu Nov 19 17:22:14 2015 -->
<table border=1>
<tr> <th> reference_name </th> <th> vt </th> <th> cnt </th> <th> dataset </th>  </tr>
  <tr> <td> 1 </td> <td> INDEL </td> <td align="right">  109119 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 1 </td> <td> SNP </td> <td align="right"> 2896960 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 1 </td> <td> SV </td> <td align="right">    1117 </td> <td> 1000Genomes </td> </tr>
  <tr> <td> 1 </td> <td> INDEL </td> <td align="right"> 1059880 </td> <td> PGP </td> </tr>
  <tr> <td> 1 </td> <td> SNP </td> <td align="right"> 1781052 </td> <td> PGP </td> </tr>
  <tr> <td> 10 </td> <td> INDEL </td> <td align="right">   67865 </td> <td> 1000Genomes </td> </tr>
   </table>

<img src="figure/variant type counts-1.png" title="plot of chunk variant type counts" alt="plot of chunk variant type counts" style="display: block; margin: auto;" />
In 1,000 Genomes the vast majority of variants are SNPs but the PGP dataset has a larger proportion of indels.

Re-plotting the data to just show the PGP variants without the log scale on the y axis:
<img src="figure/pgp variant type counts-1.png" title="plot of chunk pgp variant type counts" alt="plot of chunk pgp variant type counts" style="display: block; margin: auto;" />
 
But let's take an even closer look:

```
# Inner SELECT filters just the records in which we are interested.
# Outer SELECT performs our analysis, in this case just a count of the genotypes
# at a particular position in chromosome 3.
SELECT
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  genotype,
  COUNT(genotype) AS number_of_individuals,
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alternate_bases,
    call.callset_name,
    GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
  FROM
    [google.com:biggene:pgp_20150205.genome_calls]
  WHERE
    reference_name = 'chr3'
    AND start = 65440409)
GROUP BY
  reference_name,
  start,
  reference_bases,
  alternate_bases,
  genotype
ORDER BY
  alternate_bases,
  number_of_individuals DESC
```

We see the tabular results:
<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Thu Nov 19 17:22:17 2015 -->
<table border=1>
<tr> <th> reference_name </th> <th> start </th> <th> reference_bases </th> <th> alternate_bases </th> <th> genotype </th> <th> number_of_individuals </th>  </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> = </td> <td>  </td> <td> -1,-1 </td> <td align="right">   3 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td>  </td> <td> 0,-1 </td> <td align="right">   1 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> AAC </td> <td> 1,-1 </td> <td align="right">   3 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> AAC,C </td> <td> 1,2 </td> <td align="right">  37 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> AC,C </td> <td> 1,2 </td> <td align="right">   3 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> C </td> <td> 1,1 </td> <td align="right">  43 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> C </td> <td> 1,0 </td> <td align="right">  28 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> C </td> <td> 1,-1 </td> <td align="right">  15 </td> </tr>
  <tr> <td> chr3 </td> <td align="right"> 65440409 </td> <td> A </td> <td> C,A? </td> <td> 1,2 </td> <td align="right">   1 </td> </tr>
   </table>
So some records in the PGP data have both SNPs and INDELs, whereas 1,000 Genomes autosomal variants are bi-allelic and therefore are each of a single variant type.

Sample Level Data
-----------------

Now let's take a look at the distribution of genotypes across the PGP dataset:

```
# Count the number of genotypes for all individuals in the dataset.
SELECT
  genotype,
  COUNT(genotype) AS cnt,
FROM (
  SELECT
    GROUP_CONCAT(STRING(call.genotype)) WITHIN call AS genotype,
  FROM
    [google.com:biggene:pgp_20150205.genome_calls])
GROUP BY
  genotype
ORDER BY
  cnt DESC
```

We see the tabular results:
<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Thu Nov 19 17:22:19 2015 -->
<table border=1>
<tr> <th> genotype </th> <th> cnt </th>  </tr>
  <tr> <td> 0,0 </td> <td align="right"> 1505664389 </td> </tr>
  <tr> <td> -1,-1 </td> <td align="right"> 806555820 </td> </tr>
  <tr> <td> 1,0 </td> <td align="right"> 373226428 </td> </tr>
  <tr> <td> 1,1 </td> <td align="right"> 238037789 </td> </tr>
  <tr> <td> 1,-1 </td> <td align="right"> 59592931 </td> </tr>
  <tr> <td> 0,-1 </td> <td align="right"> 47766546 </td> </tr>
  <tr> <td> -1,0 </td> <td align="right"> 25515702 </td> </tr>
  <tr> <td> 1,2 </td> <td align="right"> 2593250 </td> </tr>
  <tr> <td> -1,1 </td> <td align="right"> 2033919 </td> </tr>
   </table>

Comparing this to 1,000 Genomes:

```
# Count the number of sample genotypes, parsed into components.
SELECT
  first_allele,
  second_allele,
  dataset,
  # Convert integer to float to avoid numeric overflow in R for integers.
  FLOAT(COUNT(1)) AS cnt
FROM (
  SELECT
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
    '1000Genomes' AS dataset
  FROM
    [genomics-public-data:1000_genomes.variants]
  OMIT RECORD IF reference_name IN ('X', 'Y', 'MT')),
  (
  SELECT
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
    'PGP' AS dataset
  FROM
    [google.com:biggene:pgp_20150205.genome_calls]
  OMIT RECORD IF reference_name IN ('chrX', 'chrY', 'chrM'))
GROUP BY
  first_allele,
  second_allele,
  dataset
```

<img src="figure/genotype heatmap-1.png" title="plot of chunk genotype heatmap" alt="plot of chunk genotype heatmap" style="display: block; margin: auto;" />
The two most notable aspects of these heatmaps is:

  1. PGP does have some autosomal variants with more than one alternate allele wherease the 1,000 Genomes phase 1 data is biallelic for the autosomes
  2. PGP contains no-calls where as 1,000 Genomes had additional processing to impute genotypes at all sites

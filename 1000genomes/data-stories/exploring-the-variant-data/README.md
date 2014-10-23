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



Basic Plots of 1k Genome Data
=============================

Min/Max Chromosomal Positions of Variants
-----------------------------------------

```
SELECT
   INTEGER(reference_name) AS chromosome,
   MIN(start) AS min,
   MAX(start) AS max
 FROM
   [genomics-public-data:1000_genomes.variants]
 OMIT RECORD IF
   reference_name IN ("X", "Y", "MT")
 GROUP BY
   chromosome
```
<img src="figure/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />
 * A basic sanity check

 * Chromosomes 13,14,15,21,22 have abnormally high min positions.
 * Chromosome 7 has low min position.
 * Hard to sequence regions?

Frequency of Variant Types Per Chromosome
-----------------------------------------

```
SELECT
  INTEGER(reference_name) AS chromosome,
  vt AS variant_type,
  COUNT(1) AS cnt
 FROM
   [genomics-public-data:1000_genomes.variants]
 OMIT RECORD IF
   reference_name IN ("X", "Y", "MT")
 GROUP BY
   chromosome,
   variant_type
```
<img src="figure/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />
 * Mostly SNPs.
 * Very few structural variants.
 * Note suppressed zero.

Types of SNP pairs (looks at both alleles)
------------------------------------------

```
SELECT
  reference_bases AS reference,
  CONCAT(
    IF(first_allele=0,
       reference_bases,
       alternate_bases),
    "|",
    IF(second_allele=0,
       reference_bases,
       alternate_bases)
    ) AS alleles,
  COUNT(1) AS cnt,
FROM
     FLATTEN((SELECT 
         reference_name,
         reference_bases,
         alternate_bases,
         vt,
         NTH(1, call.genotype) WITHIN call AS first_allele,
         NTH(2, call.genotype) WITHIN call AS second_allele
       FROM [genomics-public-data:1000_genomes.variants])
     , call)
OMIT RECORD IF
     reference_name IN ("X", "Y", "MT")
  OR first_allele < 0
  OR second_allele < 0
  OR vt != "SNP"
GROUP BY
  reference,
  alleles
```
<img src="figure/unnamed-chunk-7-1.png" title="plot of chunk unnamed-chunk-7" alt="plot of chunk unnamed-chunk-7" style="display: block; margin: auto;" />
 * Total count is #genomes * #SNPs.
 * Same data - two views

 * Red bars denote no mutation - both alleles equal reference.

 * Why are A -> C,C and A-> G,G likely, but not A -> C,G or A -> G,C?

 * Note that A & T rows are reverses of each other, as are C & G rows.

Length of Insertion/Deletion
---------------------------

```
SELECT
  CASE
    WHEN LENGTH(alternate_bases) - 
         LENGTH(reference_bases) > 50 
      THEN 51
    WHEN LENGTH(alternate_bases) - 
         LENGTH(reference_bases) < -50 
      THEN -51
    ELSE
      LENGTH(alternate_bases) - 
      LENGTH(reference_bases) 
END AS length,
  COUNT(1) AS cnt
FROM
     FLATTEN((SELECT 
         reference_name,
         reference_bases,
         alternate_bases,
         vt,
         NTH(1, call.genotype) WITHIN call AS first_allele,
         NTH(2, call.genotype) WITHIN call AS second_allele
       FROM [genomics-public-data:1000_genomes.variants])
     , call)
WHERE
      first_allele =
      POSITION(alternate_bases)
  AND LENGTH(alternate_bases) -
      LENGTH(reference_bases) != 0
OMIT RECORD IF
      reference_name IN ("X", "Y", "MT")
  AND vt != "INDEL"
GROUP BY
  length
```
<img src="figure/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />
 * +/-51 are over/under flow bins
 * -> Large tail of deletions

 * Positive length = Insertion
 * Negative length = Deletion

 * Drops off quickly.

Quality score of calls (at least, of INDELs)
--------------------------------------------

```
SELECT
  vt AS variant_type,
  quality,
  COUNT(1) AS cnt
FROM
  [genomics-public-data:1000_genomes.variants]
OMIT RECORD IF
  reference_name IN ("X", "Y", "MT")
GROUP BY
  variant_type,
  quality
```
<img src="figure/unnamed-chunk-11-1.png" title="plot of chunk unnamed-chunk-11" alt="plot of chunk unnamed-chunk-11" style="display: block; margin: auto;" />
From the 1k genome docs:
> phred-scaled quality score for the assertion made in ALT. i.e. -10log_10 prob(call in ALT is wrong). If ALT is ”.” (no variant) then this is -10log_10 p(variant), and if ALT is not ”.” this is -10log_10 p(no variant). High QUAL scores indicate high confidence calls.

From Broad Institute:
> The Phred scaled probability that a REF/ALT polymorphism exists at this site given sequencing data. Because the Phred scale is -10 * log(1-p), a value of 10 indicates a 1 in 10 chance of error, while a 100 indicates a 1 in 10^10 chance. These values can grow very large when a large amount of NGS data is used for variant calling.

Likelihood Scores for each Allele
---------------------------------

```
SELECT
  variant_type,
  likelihood,
  COUNT(1) AS cnt
FROM (
  SELECT
    variant_type,
    ROUND(100 * IF(gl > -0.5, gl,
          -0.5)) AS likelihood,
  FROM
     FLATTEN((SELECT 
         reference_name,
         vt AS variant_type,
         call.call_set_name AS genome,
         call.phaseset AS phaseset,
         call.genotype_likelihood AS gl,
         NTH(1, call.genotype) WITHIN call AS first_allele,
         NTH(2, call.genotype) WITHIN call AS second_allele
       FROM [genomics-public-data:1000_genomes.variants])
     , call)
  WHERE
        (first_allele <= second_allele
          AND POSITION(gl) = 1 +
          (second_allele *
            (second_allele + 1) / 2) +
          first_allele)
        OR (second_allele < first_allele
          AND POSITION(gl) = 1 +
          (first_allele *
            (first_allele + 1) / 2) +
          second_allele)
  OMIT RECORD IF 
       reference_name in ("X", "Y", "MT")
    OR phaseset IS NULL
)
GROUP BY
  variant_type,
  likelihood
```
<img src="figure/unnamed-chunk-13-1.png" title="plot of chunk unnamed-chunk-13" alt="plot of chunk unnamed-chunk-13" style="display: block; margin: auto;" />
This is the likelihood for the most likely set of alleles for each variant.

SNP distribution in Genomes
---------------------------

```
SELECT
  variant_info.genome AS genome,
  CONCAT(SUBSTR(sample_info.population_description,
                0, 20), "...") AS population,
  sample_info.super_population_description
                AS super_population,
  SUM(variant_info.single) AS cnt1,
  SUM(variant_info.double) AS cnt2
FROM (
  FLATTEN((
  SELECT 
    call.call_set_name AS genome,
    SOME(call.genotype > 0) AND NOT EVERY(call.genotype > 0) WITHIN call AS single,
    EVERY(call.genotype > 0) WITHIN call AS double,
   FROM [genomics-public-data:1000_genomes.variants]
   OMIT RECORD IF
     reference_name IN ("X", "Y", "MT"))
  , call)
  ) AS variant_info
  JOIN
    [genomics-public-data:1000_genomes.sample_info] AS sample_info
  ON
    variant_info.genome = sample_info.sample
GROUP BY
  genome,
  population,
  super_population
```
First by Population:
<img src="figure/unnamed-chunk-15-1.png" title="plot of chunk unnamed-chunk-15" alt="plot of chunk unnamed-chunk-15" style="display: block; margin: auto;" />
Each point is a genome:
 * X coord denotes the #SNPs w/ 1 mutation
 * Y coord denotes the #SNPs w/ 2 mutations

Cluster correlate very well with ethnicity.

Then by super population:
<img src="figure/unnamed-chunk-16-1.png" title="plot of chunk unnamed-chunk-16" alt="plot of chunk unnamed-chunk-16" style="display: block; margin: auto;" />

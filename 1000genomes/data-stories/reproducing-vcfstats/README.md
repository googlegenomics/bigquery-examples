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

Reproducing the output of vcfstats for BRCA1 in 1,000 Genomes
========================================================

Provenance for the expected result
---------------------------
First get a slice of the VCF containing just the variants within BRCA1:
```
vcftools --gzvcf ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz --chr 17 --from-bp 41196312 --to-bp 41277500 --out brca1  --recode-INFO-all --recode

VCFtools - v0.1.11
(C) Adam Auton 2009

Parameters as interpreted:
  --gzvcf ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
	--chr 17
	--to-bp 41277500
	--recode-INFO-all
	--out brca1
	--recode
	--from-bp 41196312

Using zlib version: 1.2.3.4
Versions of zlib >= 1.2.4 will be *much* faster when reading zipped VCF files.
Reading Index file.
File contains 1046733 entries and 1092 individuals.
Filtering by chromosome.
	Chromosome: 17
Keeping 1046733 entries on specified chromosomes.
Applying Required Filters.
Filtering sites by chromosome and/or position
After filtering, kept 1092 out of 1092 Individuals
After filtering, kept 879 out of a possible 1046733 Sites
Outputting VCF file... Done
Run Time = 200.00 seconds
```
Then run vcf-stats:
```
vcf-stats brca1.recode.vcf -p stats
```
Producing output files:
 * [counts](./vcfstats-output/stats.counts)
 * [dump](./vcfstats-output/stats.dump)
   * [dump-all](./vcfstats-output/stats.dump-all) for brevity
 * [indels](./vcfstats-output/stats.indels)
 * [legend](./vcfstats-output/stats.legend)
 * [private](./vcfstats-output/stats.private)
 * [qual-tstv](./vcfstats-output/stats.qual-tstv)
 * [samples-tstv](./vcfstats-output/stats.samples-tstv)
 * [shared](./vcfstats-output/stats.shared)
 * [snps](./vcfstats-output/stats.snps)
 * [tstv](./vcfstats-output/stats.tstv)
 
Reproducing the result via BigQuery
------------------------------------
[BRCA1](http://www.genecards.org/cgi-bin/carddisp.pl?gene=BRCA1) resides on chromosome 17 from position 41196312 to 41277500.  




Let’s explore variants in this gene.

```
# Count the number of variants in BRCA1
SELECT
  count(contig) as num_variants,
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500;
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:39 2014 -->
<TABLE border=1>
<TR> <TH> num_variants </TH>  </TR>
  <TR> <TD align="right"> 879 </TD> </TR>
   </TABLE>

We see that there are 879 variants on the BRCA1 gene in this dataset (equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entry all=>count). 

Let’s characterize the variants further by type.

```
# Count the number of variants by type in BRCA1.
SELECT
  vt AS variant_type,
  COUNT(vt) AS num_variants_of_type,
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
GROUP BY
  variant_type;
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:44 2014 -->
<TABLE border=1>
<TR> <TH> variant_type </TH> <TH> num_variants_of_type </TH>  </TR>
  <TR> <TD> SNP </TD> <TD align="right"> 843 </TD> </TR>
  <TR> <TD> INDEL </TD> <TD align="right">  36 </TD> </TR>
   </TABLE>

The majority are SNPs but some are INDELs (equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entries all=>snp_count and all=>indel_count).

Next lets see how the variation is shared across the samples. 

```
# Count the number of variants shared by none, shared by one sample, shared by 
# two samples, etc... in BRCA1
SELECT
  num_samples_with_variant AS num_shared_variants,
  COUNT(num_samples_with_variant) AS frequency
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    SUM(IF(0 < genotype.first_allele
        OR 0 < genotype.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500)
GROUP BY
  num_shared_variants
ORDER BY
  num_shared_variants;
```

Number of rows in result: 143 

Examing the first few rows, we see that ten variants are shared by **none** of the samples but roughly 25% of the variants are shared by only one sample:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:48 2014 -->
<TABLE border=1>
<TR> <TH> num_shared_variants </TH> <TH> frequency </TH>  </TR>
  <TR> <TD align="right">   0 </TD> <TD align="right">  10 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD align="right"> 243 </TD> </TR>
  <TR> <TD align="right">   2 </TD> <TD align="right"> 103 </TD> </TR>
  <TR> <TD align="right">   3 </TD> <TD align="right">  45 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD align="right">  40 </TD> </TR>
  <TR> <TD align="right">   5 </TD> <TD align="right">  27 </TD> </TR>
   </TABLE>

Looking at the last few rows in the result, we see that 743 variants are each shared by 2 samples and one variant is shared by nearly all samples:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:48 2014 -->
<TABLE border=1>
<TR> <TH> num_shared_variants </TH> <TH> frequency </TH>  </TR>
  <TR> <TD align="right"> 742 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right"> 743 </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD align="right"> 745 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right"> 783 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right"> 1088 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right"> 1091 </TD> <TD align="right">   1 </TD> </TR>
   </TABLE>

(equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entry all=>shared or [shared](./vcfstats-output/stats.shared))

Next let’s see how many private variants each sample has.

```
# Compute the number of variants within BRCA1 for a particular sample that are shared by 
# no other samples.
SELECT
  COUNT(sample_id) AS private_variants_count,
  sample_id
FROM
  (
  SELECT
    contig,
    position,
    reference_bases,
    IF(0 < genotype.first_allele
      OR 0 < genotype.second_allele,
      genotype.sample_id,
      NULL) AS sample_id,
    SUM(IF(0 < genotype.first_allele
        OR 0 < genotype.second_allele,
        1,
        0)) WITHIN RECORD AS num_samples_with_variant
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500
  HAVING
    num_samples_with_variant = 1
    AND sample_id IS NOT NULL)
GROUP EACH BY
  sample_id
ORDER BY
  sample_id;
```

Number of rows in result: 187 

Examing the first few rows:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:52 2014 -->
<TABLE border=1>
<TR> <TH> private_variants_count </TH> <TH> sample_id </TH>  </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00106 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00109 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00143 </TD> </TR>
  <TR> <TD align="right">   3 </TD> <TD> HG00152 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00160 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00186 </TD> </TR>
   </TABLE>

We see for example that sample HG00152 has three variants on BRAC1 shared by no other samples in this dataset (equivalent to vcf-stats [private](./vcfstats-output/stats.private)).

For the moment, let’s drill down on the SNPs in this region.  First at the variant level:

```
# Count SNPs by base pair transition across BRCA1.
SELECT
  reference_bases,
  alternate_bases AS allele,
  COUNT(alternate_bases) AS num_snps
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='SNP'
GROUP BY
  reference_bases,
  allele
ORDER BY
  reference_bases,
  allele;
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:55 2014 -->
<TABLE border=1>
<TR> <TH> reference_bases </TH> <TH> allele </TH> <TH> num_snps </TH>  </TR>
  <TR> <TD> A </TD> <TD> C </TD> <TD align="right">  33 </TD> </TR>
  <TR> <TD> A </TD> <TD> G </TD> <TD align="right">  97 </TD> </TR>
  <TR> <TD> A </TD> <TD> T </TD> <TD align="right">  25 </TD> </TR>
  <TR> <TD> C </TD> <TD> A </TD> <TD align="right">  29 </TD> </TR>
  <TR> <TD> C </TD> <TD> G </TD> <TD align="right">  20 </TD> </TR>
  <TR> <TD> C </TD> <TD> T </TD> <TD align="right"> 198 </TD> </TR>
  <TR> <TD> G </TD> <TD> A </TD> <TD align="right"> 179 </TD> </TR>
  <TR> <TD> G </TD> <TD> C </TD> <TD align="right">  51 </TD> </TR>
  <TR> <TD> G </TD> <TD> T </TD> <TD align="right">  23 </TD> </TR>
  <TR> <TD> T </TD> <TD> A </TD> <TD align="right">  27 </TD> </TR>
  <TR> <TD> T </TD> <TD> C </TD> <TD align="right"> 141 </TD> </TR>
  <TR> <TD> T </TD> <TD> G </TD> <TD align="right">  20 </TD> </TR>
   </TABLE>

We can see that some variants such as C->T are much more common than others such as T->G (equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entry all=>snp).  

Note that in this data we have variants that are not present in any of the samples.

```
# Count the number of samples that have the BRCA1 variant.
SELECT
  contig,
  position,
  reference_bases,
  SUM(IF(0 < genotype.first_allele
      OR 0 < genotype.second_allele,
      1,
      0)) WITHIN RECORD AS num_samples_with_variant
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='SNP'
ORDER BY
  num_samples_with_variant;
```

Number of rows in result: 843 

Examing the first few rows:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:53:58 2014 -->
<TABLE border=1>
<TR> <TH> contig </TH> <TH> position </TH> <TH> reference_bases </TH> <TH> num_samples_with_variant </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41223240 </TD> <TD> A </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41209158 </TD> <TD> A </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41209160 </TD> <TD> A </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41209165 </TD> <TD> A </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41218148 </TD> <TD> C </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41245488 </TD> <TD> T </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41249263 </TD> <TD> G </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41249258 </TD> <TD> C </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41247907 </TD> <TD> G </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41234420 </TD> <TD> C </TD> <TD align="right">   0 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41258228 </TD> <TD> C </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41258220 </TD> <TD> C </TD> <TD align="right">   1 </TD> </TR>
   </TABLE>

We see in the above query results the contig, position, and reference base of the 10 SNPs in this region in which all samples match the reference for both alleles (equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entry all=>nalt_0).

Next let’s drill down on the SNPs in this region by sample.

```
# Sample SNP counts for BRCA1.
SELECT
  COUNT(sample_id) AS variant_count,
  sample_id
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    genotype.sample_id AS sample_id
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    contig = '17'
    AND position BETWEEN 41196312
    AND 41277500
    AND vt ='SNP'
    AND (0 < genotype.first_allele
      OR 0 < genotype.second_allele)
    )
GROUP BY
  sample_id
ORDER BY
  sample_id;
```

Number of rows in result: 1092 

Examing the first few rows:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:54:02 2014 -->
<TABLE border=1>
<TR> <TH> variant_count </TH> <TH> sample_id </TH>  </TR>
  <TR> <TD align="right"> 117 </TD> <TD> HG00096 </TD> </TR>
  <TR> <TD align="right">   5 </TD> <TD> HG00097 </TD> </TR>
  <TR> <TD align="right"> 121 </TD> <TD> HG00099 </TD> </TR>
  <TR> <TD align="right"> 118 </TD> <TD> HG00100 </TD> </TR>
  <TR> <TD align="right">   5 </TD> <TD> HG00101 </TD> </TR>
  <TR> <TD align="right"> 126 </TD> <TD> HG00102 </TD> </TR>
   </TABLE>

We can see that some samples differ from the reference quite a bit in this region while others are quite similar (equivalent to vcf-stats [snps](./vcfstats-output/stats.snps)).

Now let’s drill down on the INDELs in this region.

```
# Count the number of INDELs differing from the reference allele by particular 
# lengths for BRCA1.
SELECT
  length_difference,
  COUNT(length_difference) AS count_of_indels_with_length_difference,
FROM (
  SELECT
    contig,
    position,
    reference_bases,
    LENGTH(reference_bases) AS ref_length,
    alternate_bases AS allele,
    LENGTH(alternate_bases) AS allele_length,
    (LENGTH(alternate_bases) - LENGTH(reference_bases)) AS length_difference,
    FROM
      [google.com:biggene:1000genomes.variants1kG]
    WHERE
      contig = '17'
      AND position BETWEEN 41196312
      AND 41277500
      AND vt ='INDEL'
    )
GROUP BY
  length_difference
ORDER BY
  length_difference;
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:54:07 2014 -->
<TABLE border=1>
<TR> <TH> length_difference </TH> <TH> count_of_indels_with_length_difference </TH>  </TR>
  <TR> <TD align="right">  -5 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right">  -3 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right">  -2 </TD> <TD align="right">   5 </TD> </TR>
  <TR> <TD align="right">  -1 </TD> <TD align="right">  13 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD align="right">   9 </TD> </TR>
  <TR> <TD align="right">   2 </TD> <TD align="right">   3 </TD> </TR>
  <TR> <TD align="right">   3 </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD align="right">   4 </TD> <TD align="right">   1 </TD> </TR>
  <TR> <TD align="right">   6 </TD> <TD align="right">   1 </TD> </TR>
   </TABLE>

We can see that the majority of the indels in this region add or remove a single base pair (equivalent to vcf-stats [dump-all](./vcfstats-output/stats.dump-all) entry all=>indels).

Now let’s characterize the number of INDELs per sample.

```
# Sample INDEL counts for BRCA1.
SELECT
  COUNT(genotype.sample_id) AS variant_count,
  genotype.sample_id AS sample_id,
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
  AND position BETWEEN 41196312
  AND 41277500
  AND vt ='INDEL'
  AND (0 < genotype.first_allele
    OR 0 < genotype.second_allele)
GROUP BY
  sample_id
ORDER BY
  sample_id;
```

Number of rows in result: 1092 

Examing the first few rows:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:54:10 2014 -->
<TABLE border=1>
<TR> <TH> variant_count </TH> <TH> sample_id </TH>  </TR>
  <TR> <TD align="right">  16 </TD> <TD> HG00096 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00097 </TD> </TR>
  <TR> <TD align="right">  15 </TD> <TD> HG00099 </TD> </TR>
  <TR> <TD align="right">  14 </TD> <TD> HG00100 </TD> </TR>
  <TR> <TD align="right">   1 </TD> <TD> HG00101 </TD> </TR>
  <TR> <TD align="right">  17 </TD> <TD> HG00102 </TD> </TR>
   </TABLE>

We can see that some samples differ from the reference quite a bit in this region while others are quite similar (equivalent to vcf-stats [indels](./vcfstats-output/stats.indels))

Another important statistic for quality control is the ratio of transitions vs. transversions in SNPs. 

```
# Compute the Ti/Tv ratio for BRCA1.
SELECT
  transitions,
  transversions,
  transitions/transversions AS titv
FROM (
  SELECT
    SUM(IF(mutation IN ('A->G',
          'G->A',
          'C->T',
          'T->C'),
        INTEGER(num_snps),
        INTEGER(0))) AS transitions,
    SUM(IF(mutation IN ('A->C',
          'C->A',
          'G->T',
          'T->G',
          'A->T',
          'T->A',
          'C->G',
          'G->C'),
        INTEGER(num_snps),
        INTEGER(0))) AS transversions,
  FROM (
    SELECT
      CONCAT(reference_bases,
        CONCAT(STRING('->'),
          alternate_bases)) AS mutation,
      COUNT(alternate_bases) AS num_snps,
    FROM
      [google.com:biggene:1000genomes.variants1kG]
    WHERE
      contig = '17'
        AND position BETWEEN 41196312
        AND 41277500
        AND vt = 'SNP'
    GROUP BY
      mutation
    ORDER BY
      mutation));
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 21 20:54:13 2014 -->
<TABLE border=1>
<TR> <TH> transitions </TH> <TH> transversions </TH> <TH> titv </TH>  </TR>
  <TR> <TD align="right"> 615 </TD> <TD align="right"> 228 </TD> <TD align="right"> 2.70 </TD> </TR>
   </TABLE>

We see a transitions vs. transversions ratio of 2.70 for this region (equivalent to vcf-stats [tstv](./vcfstats-output/stats.tstv)).

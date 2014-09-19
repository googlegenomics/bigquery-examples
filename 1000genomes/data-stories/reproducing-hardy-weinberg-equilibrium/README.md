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

Reproducing the Hardy-Weinberg Equilibrium test for BRCA1 in 1,000 Genomes
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
Then run vcftools:
```
vcftools --vcf brca1.recode.vcf --hardy
```
Producing output file: [out.hwe](./vcftools-output/out.hwe)

See [details](http://vcftools.sourceforge.net/man_latest.html#OUTPUT OPTIONS) about the --hardy option for vcftools for more detail about the calculaton.

Reproducing the result via BigQuery
------------------------------------
[BRCA1](http://www.genecards.org/cgi-bin/carddisp.pl?gene=BRCA1) resides on chromosome 17 from position 41196312 to 41277500.



Let’s compute the Hardy-Weinberg Equilibrium test for each variant within BRCA1:

```
# An example of a pattern one might use for Hardy-Weinberg Equilibrium
# queries upon 1,000 Genomes variants.  It is specifically computing
# the Hardy-Weinberg Equilibrium for the variants found in BRCA1 and
# then computing the chi-squared score for the observed versus
# expected counts for the calls.

# http://scienceprimer.com/hardy-weinberg-equilibrium-calculator
# http://www.nfstc.org/pdi/Subject07/pdi_s07_m01_02.htm
# http://www.nfstc.org/pdi/Subject07/pdi_s07_m01_02.p.htm

SELECT
  contig_name,
  start_pos,
  END,
  reference_bases,
  alt,
  vt,
  ROUND(POW(hom_ref_count - expected_hom_ref_count,
      2)/expected_hom_ref_count +
    POW(hom_alt_count - expected_hom_alt_count,
      2)/expected_hom_alt_count +
    POW(het_count - expected_het_count,
      2)/expected_het_count,
    3) AS chi_squared_score,
  total_count,
  hom_ref_count,
  ROUND(expected_hom_ref_count,
    2) AS expected_hom_ref_count,
  het_count,
  ROUND(expected_het_count,
    2) AS expected_het_count,
  hom_alt_count,
  ROUND(expected_hom_alt_count,
    2) AS expected_hom_alt_count,
  ROUND(alt_freq,
    4) AS alt_freq,
  alt_freq_from_1KG,
FROM (
  SELECT
    contig_name,
    start_pos,
    END,
    reference_bases,
    alt,
    vt,
    alt_freq_from_1KG,
    hom_ref_freq + (.5 * het_freq) AS hw_ref_freq,
    1 - (hom_ref_freq + (.5 * het_freq)) AS alt_freq,
    POW(hom_ref_freq + (.5 * het_freq),
      2) * total_count AS expected_hom_ref_count,
    POW(1 - (hom_ref_freq + (.5 * het_freq)),
      2) * total_count AS expected_hom_alt_count,
    2 * (hom_ref_freq + (.5 * het_freq))
    * (1 - (hom_ref_freq + (.5 * het_freq)))
    * total_count AS expected_het_count,
    total_count,
    hom_ref_count,
    het_count,
    hom_alt_count,
    hom_ref_freq,
    het_freq,
    hom_alt_freq,
  FROM (
    SELECT
      contig_name,
      start_pos,
      END,
      reference_bases,
      alt,
      vt,
      alt_freq_from_1KG,
      # 1000 genomes data IS bi-allelic so there IS only ever a single alt
      # We also exclude calls _where one _or both alleles were NOT called (-1)
      SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS total_count,
      SUM(0 = first_allele
        AND 0 = second_allele) WITHIN RECORD AS hom_ref_count,
      SUM((0 = first_allele
          AND 1 = second_allele)
        OR (1 = first_allele
          AND 0 = second_allele)) WITHIN RECORD AS het_count,
      SUM(1 = first_allele
        AND 1 = second_allele) WITHIN RECORD AS hom_alt_count,
      SUM(0 = first_allele
        AND 0 = second_allele) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS hom_ref_freq,
      SUM((0 = first_allele
          AND 1 = second_allele)
        OR (1 = first_allele
          AND 0 = second_allele)) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS het_freq,
      SUM(1 = first_allele
        AND 1 = second_allele) / SUM((0 = first_allele
          OR 1 = first_allele)
        AND (0 = second_allele
          OR 1 = second_allele)) WITHIN RECORD AS hom_alt_freq,
    FROM (
      SELECT
        contig_name,
        start_pos,
        END,
        reference_bases,
        GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
        vt,
        # Also return the pre-computed allelic frequency to help us check our work
        af AS alt_freq_from_1KG,
        NTH(1,
          call.genotype) WITHIN call AS first_allele,
        NTH(2,
          call.genotype) WITHIN call AS second_allele,
      FROM
        [google.com:biggene:1000genomes.phase1_variants]
      WHERE
        contig_name = '17'
        AND start_pos BETWEEN 41196312
        AND 41277500
        )))
ORDER BY
  contig_name,
  start_pos
```
Number of rows returned by this query: 879.

Displaying the first few rows of our result:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Sep 19 14:30:11 2014 -->
<TABLE border=1>
<TR> <TH> contig_name </TH> <TH> start_pos </TH> <TH> END </TH> <TH> reference_bases </TH> <TH> alt </TH> <TH> vt </TH> <TH> chi_squared_score </TH> <TH> total_count </TH> <TH> hom_ref_count </TH> <TH> expected_hom_ref_count </TH> <TH> het_count </TH> <TH> expected_het_count </TH> <TH> hom_alt_count </TH> <TH> expected_hom_alt_count </TH> <TH> alt_freq </TH> <TH> alt_freq_from_1KG </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> T </TD> <TD> SNP </TD> <TD align="right"> 34.47 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1082 </TD> <TD align="right"> 1081.03 </TD> <TD align="right">   9 </TD> <TD align="right"> 10.94 </TD> <TD align="right">   1 </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.01 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196368 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> T </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196372 </TD> <TD align="right">  </TD> <TD> T </TD> <TD> C </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196403 </TD> <TD align="right">  </TD> <TD> A </TD> <TD> G </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 2.78 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 529 </TD> <TD align="right"> 517.17 </TD> <TD align="right"> 445 </TD> <TD align="right"> 468.66 </TD> <TD align="right"> 118 </TD> <TD align="right"> 106.17 </TD> <TD align="right"> 0.31 </TD> <TD align="right"> 0.31 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196582 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> T </TD> <TD> SNP </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1081 </TD> <TD align="right"> 1081.03 </TD> <TD align="right">  11 </TD> <TD align="right"> 10.94 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.01 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196625 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> C </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196914 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.05 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1077 </TD> <TD align="right"> 1077.05 </TD> <TD align="right">  15 </TD> <TD align="right"> 14.90 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.05 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.01 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41196945 </TD> <TD align="right">  </TD> <TD> T </TD> <TD> C </TD> <TD> SNP </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1086 </TD> <TD align="right"> 1086.01 </TD> <TD align="right">   6 </TD> <TD align="right"> 5.98 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41197113 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
   </TABLE>
and the last few rows:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Sep 19 14:30:11 2014 -->
<TABLE border=1>
<TR> <TH> contig_name </TH> <TH> start_pos </TH> <TH> END </TH> <TH> reference_bases </TH> <TH> alt </TH> <TH> vt </TH> <TH> chi_squared_score </TH> <TH> total_count </TH> <TH> hom_ref_count </TH> <TH> expected_hom_ref_count </TH> <TH> het_count </TH> <TH> expected_het_count </TH> <TH> hom_alt_count </TH> <TH> expected_hom_alt_count </TH> <TH> alt_freq </TH> <TH> alt_freq_from_1KG </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41276764 </TD> <TD align="right">  </TD> <TD> T </TD> <TD> G </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41276952 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.57 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1047 </TD> <TD align="right"> 1046.48 </TD> <TD align="right">  44 </TD> <TD align="right"> 45.03 </TD> <TD align="right">   1 </TD> <TD align="right"> 0.48 </TD> <TD align="right"> 0.02 </TD> <TD align="right"> 0.02 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277067 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277103 </TD> <TD align="right">  </TD> <TD> A </TD> <TD> C </TD> <TD> SNP </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1081 </TD> <TD align="right"> 1081.03 </TD> <TD align="right">  11 </TD> <TD align="right"> 10.94 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.01 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277187 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> C </TD> <TD> SNP </TD> <TD align="right"> 49.85 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 347 </TD> <TD align="right"> 288.72 </TD> <TD align="right"> 429 </TD> <TD align="right"> 545.56 </TD> <TD align="right"> 316 </TD> <TD align="right"> 257.72 </TD> <TD align="right"> 0.49 </TD> <TD align="right"> 0.49 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277354 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277364 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277391 </TD> <TD align="right">  </TD> <TD> C </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1091 </TD> <TD align="right"> 1091.00 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277393 </TD> <TD align="right">  </TD> <TD> G </TD> <TD> A </TD> <TD> SNP </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1087 </TD> <TD align="right"> 1087.01 </TD> <TD align="right">   5 </TD> <TD align="right"> 4.99 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.00 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41277460 </TD> <TD align="right">  </TD> <TD> A </TD> <TD> G </TD> <TD> SNP </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 1092 </TD> <TD align="right"> 1081 </TD> <TD align="right"> 1081.03 </TD> <TD align="right">  11 </TD> <TD align="right"> 10.94 </TD> <TD align="right">   0 </TD> <TD align="right"> 0.03 </TD> <TD align="right"> 0.01 </TD> <TD align="right"> 0.01 </TD> </TR>
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

Most importantly, comparing these to the results in [out.hwe](./vcftools-output/out.hwe) from vcftools we see that the test scores match.

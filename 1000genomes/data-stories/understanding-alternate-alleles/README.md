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

Understanding Alternate Alleles in 1,000 Genomes VCF Data
========================================================

We know from the [FAQ](http://www.1000genomes.org/faq/are-all-genotype-calls-current-release-vcf-files-bi-allelic) that the 1,000 Genomes VCF data is [bi-allelic](http://www.1000genomes.org/faq/are-all-genotype-calls-current-release-vcf-files-bi-allelic) → meaning that each row in the source VCF has only one value in the ALT field.  So for each sample in a row, the genotype was called as either the reference or the single ALT value.  At any particular position in the genome we can have much more variation than a single alternate, so we need to understand how that is encoded in this data set.



Let’s explore the question _“Is (reference_name, start, reference_bases) a unique key in the 1,000 Genomes Data?”_


```
# Find variants on chromosome 17 that reside on the same start with the same reference base
SELECT
  reference_name,
  start,
  reference_bases,
  COUNT(start) AS num_alternates
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
GROUP BY
  reference_name,
  start,
  reference_bases
HAVING
  num_alternates > 1
ORDER BY
  reference_name,
  start,
  reference_bases
```
Number of rows returned by this query: 417.

We see the first six tabular results:
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:51:46 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> reference_bases </TH> <TH> num_alternates </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 184672 </TD> <TD> G </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 211031 </TD> <TD> C </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 240039 </TD> <TD> G </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 443435 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 533535 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 557990 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
   </TABLE>
So we see from the data that the answer to our question is “No”.

So how many rows might we see per (reference_name, start, reference_bases) tuple?

```
# Count number of alternate variants on chromosome 17 for the same start and
# reference base
SELECT
  num_alternates,
  COUNT(num_alternates) AS num_records
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    COUNT(start) AS num_alternates,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
  GROUP BY
    reference_name,
    start,
    reference_bases)
GROUP BY
  num_alternates
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:51:51 2014 -->
<TABLE border=1>
<TR> <TH> num_alternates </TH> <TH> num_records </TH>  </TR>
  <TR> <TD align="right">   1 </TD> <TD align="right"> 1045899 </TD> </TR>
  <TR> <TD align="right">   2 </TD> <TD align="right"> 417 </TD> </TR>
   </TABLE>
So we see that for any particular (reference_name, start, reference_bases) tuple the vast majority have a single alternate allele and a few have two.

Let’s examine a few of the tuples with two alternate alleles more closely.

```
# Get three particular start on chromosome 17 that have alternate variants.
SELECT
  reference_name,
  start,
  reference_bases,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  GROUP_CONCAT(names) WITHIN RECORD AS names,
  vt,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND (start = 48515942
    OR start = 48570613
    OR start = 48659342)
ORDER BY
  start,
  reference_bases,
  alt
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:51:57 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> reference_bases </TH> <TH> alt </TH> <TH> names </TH> <TH> vt </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> T </TD> <TD> G </TD> <TD> rs8076712,rs8076712 </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> T </TD> <TD> TG </TD> <TD> rs113432301,rs113432301 </TD> <TD> INDEL </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48570613 </TD> <TD> A </TD> <TD> AT </TD> <TD> rs201827568,rs201827568 </TD> <TD> INDEL </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48570613 </TD> <TD> A </TD> <TD> T </TD> <TD> rs9896330,rs9896330 </TD> <TD> SNP </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48659342 </TD> <TD> C </TD> <TD> CTGGT </TD> <TD> rs148905490,rs148905490 </TD> <TD> INDEL </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48659342 </TD> <TD> C </TD> <TD> T </TD> <TD> rs113983760,rs113983760 </TD> <TD> SNP </TD> </TR>
   </TABLE>
From this small sample, it appears that the alternate allele is either a SNP or an INDEL.

Is that the case for all the records corresponding to duplicate (reference_name, start, reference_bases) tuples?

```
# Count by variant type the number of alternate variants on chromosome 17 for the same
# start and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [genomics-public-data:1000_genomes.variants] AS variants
JOIN (
  SELECT
    reference_name,
    start,
    reference_bases,
    COUNT(start) AS num_alternates,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
  GROUP EACH BY
    reference_name,
    start,
    reference_bases
  HAVING
    num_alternates > 1) AS dups
ON
  variants.reference_name = dups.reference_name
  AND variants.start = dups.start
  AND variants.reference_bases = dups.reference_bases
WHERE
  variants.reference_name = '17'
GROUP EACH BY
  vt
ORDER BY
  vt
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:52:02 2014 -->
<TABLE border=1>
<TR> <TH> vt </TH> <TH> num_variant_type </TH>  </TR>
  <TR> <TD> INDEL </TD> <TD align="right"> 412 </TD> </TR>
  <TR> <TD> SNP </TD> <TD align="right"> 417 </TD> </TR>
  <TR> <TD> SV </TD> <TD align="right">   5 </TD> </TR>
   </TABLE>
It appears that for all records for duplicate (reference_name, start, reference_bases) tuples that we have a SNP and also an INDEL or SV.

For records corresponding to a unique (reference_name, start, reference_bases) tuple, are the variants always SNPs?

```
# Count by variant type the number of variants on chromosome 17 unique for a
# start and reference base
SELECT
  vt,
  COUNT(vt) AS num_variant_type
FROM
  [genomics-public-data:1000_genomes.variants] AS variants
JOIN EACH (
  SELECT
    reference_name,
    start,
    reference_bases,
    COUNT(start) AS num_alternates
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
  GROUP EACH BY
    reference_name,
    start,
    reference_bases
  HAVING
    num_alternates = 1) AS singles
ON
  variants.reference_name = singles.reference_name
  AND variants.start = singles.start
  AND variants.reference_bases = singles.reference_bases
WHERE
  variants.reference_name = '17'
GROUP EACH BY
  vt
ORDER BY
  vt
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:52:09 2014 -->
<TABLE border=1>
<TR> <TH> vt </TH> <TH> num_variant_type </TH>  </TR>
  <TR> <TD> INDEL </TD> <TD align="right"> 38754 </TD> </TR>
  <TR> <TD> SNP </TD> <TD align="right"> 1006702 </TD> </TR>
  <TR> <TD> SV </TD> <TD align="right"> 443 </TD> </TR>
   </TABLE>
And we see that the answer to our question is “No” - for records corresponding to a unique (reference_name, start, reference_bases) tuple, the variants are mostly SNPs but also INDELs and SVs.

So what does this all mean for a particular duplicate (reference_name, start, reference_bases) tuple for a particular sample at a particular genomic position?

```
# Get sample alleles for some specific variants.
# TODO(deflaux): update this to a user-defined function to generalize
# across more than two alternates.  For more info, see
# https://www.youtube.com/watch?v=GrD7ymUPt3M#t=1377
SELECT
  reference_name,
  start,
  alt,
  reference_bases,
  sample_id,
  CASE
  WHEN 0 = first_allele THEN reference_bases
  WHEN 1 = first_allele THEN alt1
  WHEN 2 = first_allele THEN alt2 END AS first_allele,
  CASE
  WHEN 0 = second_allele THEN reference_bases
  WHEN 1 = second_allele THEN alt1
  WHEN 2 = second_allele THEN alt2 END AS second_allele,
FROM(
  SELECT
    reference_name,
    start,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    reference_bases,
    call.call_set_name AS sample_id,
    NTH(1,
      alternate_bases) WITHIN RECORD AS alt1,
    NTH(2,
      alternate_bases) WITHIN RECORD AS alt2,
    NTH(1, call.genotype) WITHIN call AS first_allele,
    NTH(2, call.genotype) WITHIN call AS second_allele,
  FROM
    [genomics-public-data:1000_genomes.variants]
  WHERE
    reference_name = '17'
    AND start = 48515942
  HAVING
    sample_id = 'HG00100' OR sample_id = 'HG00101')
ORDER BY
  alt,
  sample_id
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:52:17 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> alt </TH> <TH> reference_bases </TH> <TH> sample_id </TH> <TH> first_allele </TH> <TH> second_allele </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> G </TD> <TD> T </TD> <TD> HG00100 </TD> <TD> T </TD> <TD> G </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> G </TD> <TD> T </TD> <TD> HG00101 </TD> <TD> T </TD> <TD> T </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> TG </TD> <TD> T </TD> <TD> HG00100 </TD> <TD> T </TD> <TD> TG </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> TG </TD> <TD> T </TD> <TD> HG00101 </TD> <TD> T </TD> <TD> T </TD> </TR>
   </TABLE>
We can see that HG00101 was called the same in both records but HG00100 was called differently.  So which is the [correct interpretation](http://vcftools.sourceforge.net/VCF-poster.pdf) for each allele at position 48515942 on chromosome 17?
```
first allele
xxxTxxxx

second allele
xxxGxxxx
or
xxxTGxxx
```
Let’s examine the quality, some INFO fields, and the genotype likelihoods a little more closely.

```
# Get data sufficient to make a judgment upon this particular sample's call.
SELECT
  reference_name,
  start,
  reference_bases AS ref,
  GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
  GROUP_CONCAT(filter) WITHIN RECORD AS filters,
  avgpost,
  rsq
  vt,
  call.call_set_name AS sample_id,
  call.phaseset AS phaseset,
  NTH(1, call.genotype) WITHIN call AS first_allele,
  NTH(2, call.genotype) WITHIN call AS second_allele,
  call.ds AS ds,
  GROUP_CONCAT(STRING(call.genotype_likelihood)) WITHIN call AS likelihoods,
FROM
  [genomics-public-data:1000_genomes.variants]
WHERE
  reference_name = '17'
  AND start = 48515942
HAVING
  sample_id = 'HG00100'
ORDER BY
  alt
```
<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:52:22 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> ref </TH> <TH> alt </TH> <TH> filters </TH> <TH> avgpost </TH> <TH> vt </TH> <TH> sample_id </TH> <TH> phaseset </TH> <TH> first_allele </TH> <TH> second_allele </TH> <TH> ds </TH> <TH> likelihoods </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> T </TD> <TD> G </TD> <TD> PASS </TD> <TD align="right"> 0.99 </TD> <TD align="right"> 0.99 </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   1 </TD> <TD align="right"> 1.00 </TD> <TD> -3.52,0,-2.65 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 48515942 </TD> <TD> T </TD> <TD> TG </TD> <TD> PASS </TD> <TD align="right"> 0.95 </TD> <TD align="right"> 0.90 </TD> <TD> HG00100 </TD> <TD> * </TD> <TD align="right">   0 </TD> <TD align="right">   1 </TD> <TD align="right"> 0.90 </TD> <TD> 0,-0.6,-5.4 </TD> </TR>
   </TABLE>
The [likelihoods](http://faculty.washington.edu/browning/beagle/intro-to-vcf.html) correspond to the REF/REF, REF/ALT, and ALT/ALT genotypes in that order.  See the table schema for details about the other fields.

So a question for our users who have much experience in this domain, which variant is more likely for the second allele of HG00100?

### But we digress . . .

Our original question was _“Is (reference_name, start, reference_bases) a unique key in the 1,000 Genomes Data?”_ which we know is false.  So which columns do constitute a unique key?


```
# This query demonstrates that some additional field is needed to
# comprise a unique key for the rows in the table.
SELECT
  reference_name,
  start,
  reference_bases,
  alt,
  vt,
  COUNT(1) AS cnt
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
  FROM
    [genomics-public-data:1000_genomes.variants])
  GROUP EACH BY
  reference_name,
  start,
  reference_bases,
  alt,
  vt
HAVING
  cnt > 1
ORDER BY
  reference_name
```

<!-- html table generated in R 3.1.1 by xtable 1.7-3 package -->
<!-- Fri Oct  3 08:52:27 2014 -->
<TABLE border=1>
<TR> <TH> reference_name </TH> <TH> start </TH> <TH> reference_bases </TH> <TH> alt </TH> <TH> vt </TH> <TH> cnt </TH>  </TR>
  <TR> <TD> 14 </TD> <TD align="right"> 106885900 </TD> <TD> G </TD> <TD> &lt;U+003c&gt;DEL&lt;U+003e&gt; </TD> <TD> SV </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 19 </TD> <TD align="right"> 48773400 </TD> <TD> C </TD> <TD> &lt;U+003c&gt;DEL&lt;U+003e&gt; </TD> <TD> SV </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 6 </TD> <TD align="right"> 26745500 </TD> <TD> C </TD> <TD> &lt;U+003c&gt;DEL&lt;U+003e&gt; </TD> <TD> SV </TD> <TD align="right">   2 </TD> </TR>
   </TABLE>
Not quite.  We see a few structural variant deletions called at the same position.

Let's add in the `end` column:

```
# This query demonstrates that an additional field, 'end', is needed to  
# comprise a unique key for the rows in the table.
SELECT
  reference_name,
  start,
  reference_bases,
  alt,
  vt,
  end,
  COUNT(1) AS cnt
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    vt,
    end,
  FROM
    [genomics-public-data:1000_genomes.variants])
  GROUP EACH BY
  reference_name,
  start,
  reference_bases,
  alt,
  vt,
  end
HAVING
  cnt > 1
```


```r
print(expect_true(is.null(result)))
```

```
As expected: is.null(result) is true 
```

And now we have it, a unique key is: (reference_name, start, reference_bases, alternate_bases, vt, end)

Lastly, what is a minimal unique key?

```
# This query demonstrates the minimal set of fields needed to  
# comprise a unique key for the rows in the table.
SELECT
  reference_name,
  start,
  alt,
  end,
  COUNT(1) AS cnt
FROM (
  SELECT
    reference_name,
    start,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    end,
  FROM
    [genomics-public-data:1000_genomes.variants])
  GROUP EACH BY
  reference_name,
  start,
  alt,
  end
HAVING
  cnt > 1
```


```r
print(expect_true(is.null(result)))
```

```
As expected: is.null(result) is true 
```

We see that a minimal unique key is: (reference_name, start, alternate_bases, end) or alternatively (reference_name, start, end, vt)

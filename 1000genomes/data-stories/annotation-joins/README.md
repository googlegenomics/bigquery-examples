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

Annotation JOINs
========================================================

In this data story we explore JOINing variant data in BigQuery with several annotation databases.


```r
require(bigrquery)
require(testthat)
require(xtable)
billing_project = "google.com:biggene"  # put your projectID here
```


Let's start by getting an idea of the number of rows in each of our tables.

```r
tables = c("variants1kG", "pedigree", "sample_info", "clinvar", "clinvar_disease_names", 
    "known_genes", "known_genes_aliases")
lapply(tables, function(table) {
    result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
        query = paste("SELECT count(*) AS cnt FROM [google.com:biggene:1000genomes.", 
            table, "]", sep = ""), billing = billing_project)
    paste(table, result, sep = ": ")
})
```

```
## [[1]]
## [1] "variants1kG: 39706715"
## 
## [[2]]
## [1] "pedigree: 3501"
## 
## [[3]]
## [1] "sample_info: 3500"
## 
## [[4]]
## [1] "clinvar: 71356"
## 
## [[5]]
## [1] "clinvar_disease_names: 16020"
## 
## [[6]]
## [1] "known_genes: 82960"
## 
## [[7]]
## [1] "known_genes_aliases: 612731"
```

We can see that all the annotation databases are dwarfed in size by the data in the variants table.

## JOINs that check whether a position overlaps an interval

### JOINing Sample SNP Variants with ClinVar


```r
sql = readChar("../../sql/individual-clinically-concerning-variants.sql", nchars = 1e+06)
cat(sql)
```

```
# Retrieve the SNPs identified by ClinVar as pathenogenic or a risk factor for a particular sample
SELECT
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
FROM (
  SELECT
    contig,
    position,
    ref,
    alt,
    genotype.sample_id AS sample_id,
    clinicalsignificance,
    disease_id,
  FROM
    FLATTEN([google.com:biggene:1000genomes.variants1kG],
      alternate_bases) AS var
  JOIN (
    SELECT
      chromosome,
      start,
      clinicalsignificance,
      REGEXP_EXTRACT(hgvs_c,
        r'(\w)>\w') AS ref,
      REGEXP_EXTRACT(hgvs_c,
        r'\w>(\w)')  AS alt,
      REGEXP_EXTRACT(phenotypeids,
        r'MedGen:(\w+)') AS disease_id,
    FROM
      [google.com:biggene:1000genomes.clinvar]
    WHERE
      type='single nucleotide variant'
      AND (clinicalsignificance CONTAINS 'risk factor'
        OR clinicalsignificance CONTAINS 'pathogenic'
        OR clinicalsignificance CONTAINS 'Pathogenic')
      ) AS clin
  ON
    var.contig = clin.chromosome
    AND var.position = clin.start
    AND reference_bases = ref
    AND alternate_bases = alt
  WHERE
    genotype.sample_id = 'NA19764'
    AND var.vt='SNP'
    AND (var.genotype.first_allele > 0
      OR var.genotype.second_allele > 0)) AS sig
JOIN
  [google.com:biggene:1000genomes.clinvar_disease_names] AS names
ON
  names.conceptid = sig.disease_id
GROUP BY
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  sample_id,
ORDER BY
  clinicalsignificance,
  contig,
  position;
```

```r
result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
    query = sql, billing = billing_project)
dim(result)
```

```
[1] 53  7
```

Display the first few rows of our result

```r
print(xtable(head(result)), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> contig </TH> <TH> position </TH> <TH> ref </TH> <TH> alt </TH> <TH> clinicalsignificance </TH> <TH> diseasename </TH> <TH> sample_id </TH>  </TR>
  <TR> <TD> 11 </TD> <TD align="right"> 88911696 </TD> <TD> C </TD> <TD> A </TD> <TD> Benign;Pathogenic </TD> <TD> Oculocutaneous albinism type 1A </TD> <TD> NA19764 </TD> </TR>
  <TR> <TD> 11 </TD> <TD align="right"> 113270828 </TD> <TD> G </TD> <TD> A </TD> <TD> Benign;Pathogenic </TD> <TD> Dopamine receptor d2, reduced brain density of </TD> <TD> NA19764 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 7123838 </TD> <TD> C </TD> <TD> T </TD> <TD> Benign;Pathogenic </TD> <TD> Very long chain acyl-CoA dehydrogenase deficiency </TD> <TD> NA19764 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 6292915 </TD> <TD> A </TD> <TD> G </TD> <TD> Benign;Pathogenic </TD> <TD> AllHighlyPenetrant </TD> <TD> NA19764 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 187113041 </TD> <TD> C </TD> <TD> G </TD> <TD> Benign;Pathogenic </TD> <TD> Bietti crystalline corneoretinal dystrophy </TD> <TD> NA19764 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 45360730 </TD> <TD> T </TD> <TD> C </TD> <TD> Benign;Pathogenic;risk factor </TD> <TD> Myocardial infarction </TD> <TD> NA19764 </TD> </TR>
   </TABLE>

We can see that this indivudual has 53 clinically concerning variants.

### JOINing Sample SNP Variants with ClinVar, Grouped by Family

```r
sql = readChar("../../sql/familial-shared-clinically-concerning-variants.sql", 
    nchars = 1e+06)
cat(sql)
```

```
# Retrieve the SNPs identified by ClinVar as pathenogenic or a risk factor, counting the 
# number of family members sharing the SNP
SELECT
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
FROM (
  SELECT
    contig,
    position,
    ref,
    alt,
    clinicalsignificance,
    disease_id,
    family_id,
    COUNT(*) AS num_family_members_with_variant,
  FROM
    (FLATTEN(
        (
        SELECT
          contig,
          position,
          ref,
          alt,
          genotype.sample_id AS sample_id,
          clinicalsignificance,
          disease_id,
        FROM
          FLATTEN([google.com:biggene:1000genomes.variants1kG],
            alternate_bases) AS var
        JOIN (
          SELECT
            chromosome,
            start,
            clinicalsignificance,
            REGEXP_EXTRACT(hgvs_c,
              r'(\w)>\w') AS ref,
            REGEXP_EXTRACT(hgvs_c,
              r'\w>(\w)')  AS alt,
            REGEXP_EXTRACT(phenotypeids,
              r'MedGen:(\w+)') AS disease_id,
          FROM
            [google.com:biggene:1000genomes.clinvar]
          WHERE
            type='single nucleotide variant'
            AND (clinicalsignificance CONTAINS 'risk factor'
              OR clinicalsignificance CONTAINS 'pathogenic'
              OR clinicalsignificance CONTAINS 'Pathogenic')
            ) AS clin
        ON
          var.contig = clin.chromosome
          AND var.position = clin.start
          AND reference_bases = ref
          AND alternate_bases = alt
        WHERE
          var.vt='SNP'
          AND (var.genotype.first_allele > 0
            OR var.genotype.second_allele > 0)),
        var.genotype)) AS sig
  JOIN
    [google.com:biggene:1000genomes.pedigree] AS ped
  ON
    sig.sample_id = ped.individual_id
  GROUP BY
    contig,
    position,
    ref,
    alt,
    clinicalsignificance,
    disease_id,
    family_id) families
JOIN
  [google.com:biggene:1000genomes.clinvar_disease_names] AS names
ON
  names.conceptid = families.disease_id
GROUP BY
  contig,
  position,
  ref,
  alt,
  clinicalsignificance,
  diseasename,
  family_id,
  num_family_members_with_variant,
ORDER BY
  num_family_members_with_variant DESC,
  clinicalsignificance,
  contig,
  position;
```

```r
result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
    query = sql, billing = billing_project)
```

```
Retrieving data:  2.9sRetrieving data:  5.9sRetrieving data: 11.5sRetrieving data: 15.2s
```

```r
dim(result)
```

```
[1] 42863     8
```

Display the first few rows of our result

```r
print(xtable(head(result)), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> contig </TH> <TH> position </TH> <TH> ref </TH> <TH> alt </TH> <TH> clinicalsignificance </TH> <TH> diseasename </TH> <TH> family_id </TH> <TH> num_family_members_with_variant </TH>  </TR>
  <TR> <TD> 11 </TD> <TD align="right"> 88911696 </TD> <TD> C </TD> <TD> A </TD> <TD> Benign;Pathogenic </TD> <TD> Oculocutaneous albinism type 1A </TD> <TD> 1362 </TD> <TD align="right">   4 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 6292915 </TD> <TD> A </TD> <TD> G </TD> <TD> Benign;Pathogenic </TD> <TD> AllHighlyPenetrant </TD> <TD> 1346 </TD> <TD align="right">   4 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 6292915 </TD> <TD> A </TD> <TD> G </TD> <TD> Benign;Pathogenic </TD> <TD> AllHighlyPenetrant </TD> <TD> 1362 </TD> <TD align="right">   4 </TD> </TR>
  <TR> <TD> 4 </TD> <TD align="right"> 187113041 </TD> <TD> C </TD> <TD> G </TD> <TD> Benign;Pathogenic </TD> <TD> Bietti crystalline corneoretinal dystrophy </TD> <TD> 1444 </TD> <TD align="right">   4 </TD> </TR>
  <TR> <TD> 19 </TD> <TD align="right"> 49206674 </TD> <TD> G </TD> <TD> A </TD> <TD> Benign;Pathogenic;association </TD> <TD> Norwalk virus infection, resistance to </TD> <TD> 1346 </TD> <TD align="right">   4 </TD> </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 53676448 </TD> <TD> G </TD> <TD> A </TD> <TD> Benign;risk factor </TD> <TD> Encephalopathy, acute, infection-induced, 4, susceptibility to </TD> <TD> 1346 </TD> <TD align="right">   4 </TD> </TR>
   </TABLE>

We can see that some variants are shared by as many as four family members.

## JOINs that check whether an interval overlaps another interval

### JOINing Chromosome 17 Variants with Gene Names

Next we'll JOIN our variants with gene names.  Note that the JOIN criteria is simple - just matching on the chromosome, but the WHERE clause ensures the intervals overlap.

```r
sql = readChar("../../sql/gene-variant-counts.sql", nchars = 1e+06)
cat(sql)
```

```
# Count the number of variants per gene within chromosome 17
SELECT
  gene_variants.name AS name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    name,
    var.contig AS contig,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      contig,
      position AS variant_start,
      IF(vt != 'SV',
        position + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      [google.com:biggene:1000genomes.variants1kG]) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS contig,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:1000genomes.known_genes] ) AS genes
  ON
    var.contig = genes.contig
  WHERE
    var.contig = '17'
    AND (( var.variant_start <= var.variant_end
        AND NOT (
          var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
      OR (var.variant_start <= var.variant_end
        AND NOT (
          var.variant_end > genes.gene_end || var.variant_start < genes.gene_start)))
  GROUP BY
    name,
    contig,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:1000genomes.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt;
```

```r
result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
    query = sql, billing = billing_project)
```

```r
dim(result)
```

```
[1] 4382    8
```

Display the first few rows of our result

```r
print(xtable(head(result)), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> name </TH> <TH> contig </TH> <TH> min_variant_start </TH> <TH> max_variant_start </TH> <TH> gene_start </TH> <TH> gene_end </TH> <TH> cnt </TH> <TH> gene_aliases </TH>  </TR>
  <TR> <TD> uc031reh.1 </TD> <TD> 17 </TD> <TD align="right"> 68071614 </TD> <TD align="right"> 68131595 </TD> <TD align="right"> 68071365 </TD> <TD align="right"> 68131746 </TD> <TD align="right"> 944 </TD> <TD> IRK16_HUMAN,KCNJ16,NM_001270422,NP_733937,Q9NPI9,uc002jin.3,uc031reh.1 </TD> </TR>
  <TR> <TD> uc002jin.4 </TD> <TD> 17 </TD> <TD align="right"> 68071614 </TD> <TD align="right"> 68131595 </TD> <TD align="right"> 68071365 </TD> <TD align="right"> 68131746 </TD> <TD align="right"> 944 </TD> <TD> IRK16_HUMAN,KCNJ16,NM_018658,NP_733937,Q9NPI9,uc002jin.3,uc002jin.4 </TD> </TR>
  <TR> <TD> uc002jio.4 </TD> <TD> 17 </TD> <TD align="right"> 68071614 </TD> <TD align="right"> 68131595 </TD> <TD align="right"> 68071365 </TD> <TD align="right"> 68131746 </TD> <TD align="right"> 944 </TD> <TD> IRK16_HUMAN,KCNJ16,NM_170741,NP_733937,Q9NPI9,uc002jio.3,uc002jio.4 </TD> </TR>
  <TR> <TD> uc002jip.4 </TD> <TD> 17 </TD> <TD align="right"> 68101013 </TD> <TD align="right"> 68131595 </TD> <TD align="right"> 68100994 </TD> <TD align="right"> 68131746 </TD> <TD align="right"> 461 </TD> <TD> BC033038,IRK16_HUMAN,KCNJ16,NM_170741,NP_733937,Q9NPI9,uc002jip.3,uc002jip.4 </TD> </TR>
  <TR> <TD> uc002jiq.3 </TD> <TD> 17 </TD> <TD align="right"> 68124202 </TD> <TD align="right"> 68131595 </TD> <TD align="right"> 68124166 </TD> <TD align="right"> 68131746 </TD> <TD align="right"> 103 </TD> <TD> AK225944,IRK16_HUMAN,KCNJ16,NM_170741,NP_733937,Q9NPI9,uc002jiq.3 </TD> </TR>
  <TR> <TD> uc021uch.1 </TD> <TD> 17 </TD> <TD align="right"> 68128241 </TD> <TD align="right"> 68129461 </TD> <TD align="right"> 68128228 </TD> <TD align="right"> 68129485 </TD> <TD align="right">  26 </TD> <TD> CCDS11687,IRK16_HUMAN,KCNJ16,NM_170741,NP_733937,Q9NPI9,uc021uch.1 </TD> </TR>
   </TABLE>

And drilling down to just the genes with name matching BRCA1

```r
brca1_all = subset(result, grepl("BRCA1", gene_aliases))
dim(brca1_all)
```

```
## [1] 20  8
```



```r
print(xtable(brca1_all), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> name </TH> <TH> contig </TH> <TH> min_variant_start </TH> <TH> max_variant_start </TH> <TH> gene_start </TH> <TH> gene_end </TH> <TH> cnt </TH> <TH> gene_aliases </TH>  </TR>
  <TR> <TD> uc010whl.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41276093 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41276132 </TD> <TD align="right"> 839 </TD> <TD> BRCA1,E7ETR2,E7ETR2_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whl.2 </TD> </TR>
  <TR> <TD> uc010whm.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 854 </TD> <TD> BRCA1,C6YB45,C6YB45_HUMAN,DQ333386,uc010whm.2 </TD> </TR>
  <TR> <TD> uc002icp.4 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 854 </TD> <TD> BRCA1,NR_027676,P38398-2,RNF53,uc002icp.4 </TD> </TR>
  <TR> <TD> uc002icu.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,NM_007299,NP_009230,P38398-6,RNF53,uc002icu.3 </TD> </TR>
  <TR> <TD> uc010cyx.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyx.3 </TD> </TR>
  <TR> <TD> uc002ict.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,J3KQF3,J3KQF3_HUMAN,NM_007300,NP_009231,uc002ict.3 </TD> </TR>
  <TR> <TD> uc010whn.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,DQ363751,G3XAC3,G3XAC3_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whn.2 </TD> </TR>
  <TR> <TD> uc010who.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,C6YB46,C6YB46_HUMAN,DQ333387,uc010who.2,uc010who.3 </TD> </TR>
  <TR> <TD> uc002icq.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007294,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002icq.3 </TD> </TR>
  <TR> <TD> uc010whp.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41322380 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41322420 </TD> <TD align="right"> 1383 </TD> <TD> AK293762,B4DES0,B4DES0_HUMAN,BRCA1,NM_007298,NP_009229,uc010whp.2 </TD> </TR>
  <TR> <TD> uc010whq.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41256877 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41256973 </TD> <TD align="right"> 464 </TD> <TD> BC046142,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whq.1 </TD> </TR>
  <TR> <TD> uc002idc.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 674 </TD> <TD> BC085615,BRCA1,E7EUM2,E7EUM2_HUMAN,NM_007299,NP_009230,uc002idc.1 </TD> </TR>
  <TR> <TD> uc010whr.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 674 </TD> <TD> AK316200,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whr.1 </TD> </TR>
  <TR> <TD> uc002idd.3 </TD> <TD> 17 </TD> <TD align="right"> 41243190 </TD> <TD align="right"> 41276093 </TD> <TD align="right"> 41243116 </TD> <TD align="right"> 41276132 </TD> <TD align="right"> 359 </TD> <TD> AY354539,BRCA1,NM_007294,NP_009225,Q5YLB2,Q5YLB2_HUMAN,uc002idd.3 </TD> </TR>
  <TR> <TD> uc002ide.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41256877 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41256973 </TD> <TD align="right"> 167 </TD> <TD> BC038947,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002ide.1 </TD> </TR>
  <TR> <TD> uc010cyy.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 372 </TD> <TD> AK308084,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyy.1 </TD> </TR>
  <TR> <TD> uc010whs.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 377 </TD> <TD> BC114562,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010whs.1 </TD> </TR>
  <TR> <TD> uc010cyz.2 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> BC114511,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyz.2 </TD> </TR>
  <TR> <TD> uc010cza.2 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> AK307553,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cza.2 </TD> </TR>
  <TR> <TD> uc010wht.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> BC106746,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010wht.1 </TD> </TR>
   </TABLE>

We see how many variants we have within these genes for the full dataset.

### JOINing Chromosome 17 Variants for a Particular Sample with Gene Names

Now let's look at these sample variants for a particular sample

```r
sql = readChar("../../sql/sample-gene-variant-counts.sql", nchars = 1e+06)
cat(sql)
```

```
# Count the number of variants per gene within chromosome 17 for a particular sample 
SELECT
  sample_id,
  gene_variants.name AS name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    sample_id,
    name,
    var.contig AS contig,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      genotype.sample_id AS sample_id,
      contig,
      position AS variant_start,
      IF(vt != 'SV',
        position + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      FLATTEN([google.com:biggene:1000genomes.variants1kG],
        alternate_bases)
    WHERE
      contig = '17'
      AND genotype.sample_id = 'NA19764'
      AND (genotype.first_allele > 0
        OR genotype.second_allele > 0)
      ) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS contig,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:1000genomes.known_genes] ) AS genes
  ON
    var.contig = genes.contig
  WHERE
    ( var.variant_start <= var.variant_end
      AND NOT (
        var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
    OR (var.variant_start <= var.variant_end
      AND NOT (
        var.variant_end > genes.gene_end || var.variant_start < genes.gene_start))
  GROUP BY
    sample_id,
    name,
    contig,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:1000genomes.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  sample_id,
  name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt;
```

```r
result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
    query = sql, billing = billing_project)
```

```r
dim(result)
```

```
[1] 3958    9
```

Display the first few rows of our result

```r
print(xtable(head(result)), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> sample_id </TH> <TH> name </TH> <TH> contig </TH> <TH> min_variant_start </TH> <TH> max_variant_start </TH> <TH> gene_start </TH> <TH> gene_end </TH> <TH> cnt </TH> <TH> gene_aliases </TH>  </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002hnm.3 </TD> <TD> 17 </TD> <TD align="right"> 35443085 </TD> <TD align="right"> 35713644 </TD> <TD align="right"> 35441926 </TD> <TD align="right"> 35716059 </TD> <TD align="right"> 249 </TD> <TD> ACAC,ACACA,ACACA_HUMAN,ACC1,ACCA,B2RP68,NM_198836,NP_942135,Q13085,Q6KEV6,Q6XDA8,Q7Z2G8,Q7Z561,Q7Z563,Q7Z564,Q86WB2,Q86WB3,uc002hnm.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002hnn.3 </TD> <TD> 17 </TD> <TD align="right"> 35443085 </TD> <TD align="right"> 35766475 </TD> <TD align="right"> 35441926 </TD> <TD align="right"> 35766902 </TD> <TD align="right"> 311 </TD> <TD> ACAC,ACACA,ACACA_HUMAN,ACC1,ACCA,B2RP68,NM_198839,NP_942135,Q13085,Q6KEV6,Q6XDA8,Q7Z2G8,Q7Z561,Q7Z563,Q7Z564,Q86WB2,Q86WB3,uc002hnn.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002hno.3 </TD> <TD> 17 </TD> <TD align="right"> 35443085 </TD> <TD align="right"> 35766475 </TD> <TD align="right"> 35441926 </TD> <TD align="right"> 35766902 </TD> <TD align="right"> 311 </TD> <TD> ACAC,ACACA,ACC1,ACCA,NM_198834,NP_942135,Q13085-4,uc002hno.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010cuz.3 </TD> <TD> 17 </TD> <TD align="right"> 35580861 </TD> <TD align="right"> 35713644 </TD> <TD align="right"> 35578438 </TD> <TD align="right"> 35716059 </TD> <TD align="right"> 133 </TD> <TD> ACAC,ACACA,ACACA_HUMAN,ACC1,ACCA,AK309084,B2RP68,NM_198834,NP_942131,Q13085,Q6KEV6,Q6XDA8,Q7Z2G8,Q7Z561,Q7Z563,Q7Z564,Q86WB2,Q86WB3,uc010cuz.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002hnq.2 </TD> <TD> 17 </TD> <TD align="right"> 35632584 </TD> <TD align="right"> 35766475 </TD> <TD align="right"> 35631083 </TD> <TD align="right"> 35766902 </TD> <TD align="right"> 146 </TD> <TD> ACACA,AK308905,uc002hnq.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002hnp.1 </TD> <TD> 17 </TD> <TD align="right"> 35642592 </TD> <TD align="right"> 35713644 </TD> <TD align="right"> 35641738 </TD> <TD align="right"> 35716059 </TD> <TD align="right">  67 </TD> <TD> ACACA,AY315622,uc002hnp.1 </TD> </TR>
   </TABLE>

And drilling down to just the genes with name matching BRCA1

```r
brca1_one = subset(result, grepl("BRCA1", gene_aliases))
dim(brca1_one)
```

```
## [1] 20  9
```



```r
print(xtable(brca1_one), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> sample_id </TH> <TH> name </TH> <TH> contig </TH> <TH> min_variant_start </TH> <TH> max_variant_start </TH> <TH> gene_start </TH> <TH> gene_end </TH> <TH> cnt </TH> <TH> gene_aliases </TH>  </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whl.2 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41275645 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41276132 </TD> <TD align="right"> 129 </TD> <TD> BRCA1,E7ETR2,E7ETR2_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whl.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whm.2 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,C6YB45,C6YB45_HUMAN,DQ333386,uc010whm.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002icp.4 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,NR_027676,P38398-2,RNF53,uc002icp.4 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002icu.3 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,NM_007299,NP_009230,P38398-6,RNF53,uc002icu.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010cyx.3 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyx.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002ict.3 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,J3KQF3,J3KQF3_HUMAN,NM_007300,NP_009231,uc002ict.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whn.2 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,DQ363751,G3XAC3,G3XAC3_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whn.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010who.3 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,C6YB46,C6YB46_HUMAN,DQ333387,uc010who.2,uc010who.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002icq.3 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 132 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007294,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002icq.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whp.2 </TD> <TD> 17 </TD> <TD align="right"> 41196408 </TD> <TD align="right"> 41321910 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41322420 </TD> <TD align="right"> 218 </TD> <TD> AK293762,B4DES0,B4DES0_HUMAN,BRCA1,NM_007298,NP_009229,uc010whp.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whq.1 </TD> <TD> 17 </TD> <TD align="right"> 41215825 </TD> <TD align="right"> 41255111 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41256973 </TD> <TD align="right">  75 </TD> <TD> BC046142,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whq.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002idc.1 </TD> <TD> 17 </TD> <TD align="right"> 41215825 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 104 </TD> <TD> BC085615,BRCA1,E7EUM2,E7EUM2_HUMAN,NM_007299,NP_009230,uc002idc.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whr.1 </TD> <TD> 17 </TD> <TD align="right"> 41215825 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 104 </TD> <TD> AK316200,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whr.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002idd.3 </TD> <TD> 17 </TD> <TD align="right"> 41243190 </TD> <TD align="right"> 41275645 </TD> <TD align="right"> 41243116 </TD> <TD align="right"> 41276132 </TD> <TD align="right">  50 </TD> <TD> AY354539,BRCA1,NM_007294,NP_009225,Q5YLB2,Q5YLB2_HUMAN,uc002idd.3 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc002ide.1 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41255111 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41256973 </TD> <TD align="right">  23 </TD> <TD> BC038947,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002ide.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010cyy.1 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277340 </TD> <TD align="right">  52 </TD> <TD> AK308084,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyy.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010whs.1 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277468 </TD> <TD align="right">  52 </TD> <TD> BC114562,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010whs.1 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010cyz.2 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right">  52 </TD> <TD> BC114511,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyz.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010cza.2 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right">  52 </TD> <TD> AK307553,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cza.2 </TD> </TR>
  <TR> <TD> NA19764 </TD> <TD> uc010wht.1 </TD> <TD> 17 </TD> <TD align="right"> 41244000 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right">  52 </TD> <TD> BC106746,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010wht.1 </TD> </TR>
   </TABLE>


Let's compare these to the dataset level gene counts

```r
brca1_all$name == brca1_one$name
```

```
##  [1] TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE TRUE
## [15] TRUE TRUE TRUE TRUE TRUE TRUE
```

```r
expect_that(brca1_all$name, equals(brca1_one$name))
brca1_all$cnt - brca1_one$cnt
```

```
##  [1]  710  722  722  727  727  727  727  727  727 1165  389  570  570  309
## [15]  144  320  325  325  325  325
```

```r
mean(brca1_all$cnt - brca1_one$cnt)
```

```
## [1] 564.1
```

```r
qplot(brca1_all$cnt, brca1_one$cnt, xlim = c(0, max(brca1_all$cnt)), ylim = c(0, 
    max(brca1_all$cnt)), xlab = "count of variants per gene for the full dataset", 
    ylab = "count of variants per gene for one sample", )
```

```
## Error: could not find function "qplot"
```

And we see that our sample has variants within the same set of genes, but many fewer per gene.

### JOINing All Variants with Gene Names
Let's go bigger now and run this on the entire 1,000 Genomes dataset.

```r
sql = readChar("../../sql/specific-gene-variant-counts.sql", nchars = 1e+06)
cat(sql)
```

```
# Scan the entirety of 1,000 Genomes counting the number of variants found 
# within the BRCA1 and APOE genes
SELECT
  gene_variants.name AS name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt,
  GROUP_CONCAT(alias) AS gene_aliases,
FROM (
  SELECT
    name,
    var.contig AS contig,
    MIN(variant_start) AS min_variant_start,
    MAX(variant_end) AS max_variant_start,
    gene_start,
    gene_end,
    COUNT(*) AS cnt
  FROM (
    SELECT
      contig,
      position AS variant_start,
      IF(vt != 'SV',
        position + (LENGTH(alternate_bases) - LENGTH(reference_bases)),
        END) AS variant_end,
    FROM
      [google.com:biggene:1000genomes.variants1kG]) AS var
  JOIN (
    SELECT
      name,
      REGEXP_EXTRACT(chrom,
        r'chr(\d+)') AS contig,
      txStart AS gene_start,
      txEnd AS gene_end,
    FROM
      [google.com:biggene:1000genomes.known_genes] ) AS genes
  ON
    var.contig = genes.contig
  WHERE
    (( var.variant_start <= var.variant_end
        AND NOT (
          var.variant_start > genes.gene_end || var.variant_end < genes.gene_start))
      OR (var.variant_start <= var.variant_end
        AND NOT (
          var.variant_end > genes.gene_end || var.variant_start < genes.gene_start)))
  GROUP BY
    name,
    contig,
    gene_start,
    gene_end) AS gene_variants
JOIN
  [google.com:biggene:1000genomes.known_genes_aliases] AS gene_aliases
ON
  gene_variants.name = gene_aliases.name
GROUP BY
  name,
  contig,
  min_variant_start,
  max_variant_start,
  gene_start,
  gene_end,
  cnt
HAVING
  gene_aliases CONTAINS 'BRCA1'
  OR gene_aliases CONTAINS 'APOE';
```

```r
result = query_exec(project = "google.com:biggene", dataset = "1000genomes", 
    query = sql, billing = billing_project)
dim(result)
```

```
[1] 26  8
```

Display the rows of our result

```r
print(xtable(result), type = "html", include.rownames = F)
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Thu Apr 17 17:46:42 2014 -->
<TABLE border=1>
<TR> <TH> name </TH> <TH> contig </TH> <TH> min_variant_start </TH> <TH> max_variant_start </TH> <TH> gene_start </TH> <TH> gene_end </TH> <TH> cnt </TH> <TH> gene_aliases </TH>  </TR>
  <TR> <TD> uc010whl.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41276093 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41276132 </TD> <TD align="right"> 839 </TD> <TD> BRCA1,E7ETR2,E7ETR2_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whl.2 </TD> </TR>
  <TR> <TD> uc010whm.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 854 </TD> <TD> BRCA1,C6YB45,C6YB45_HUMAN,DQ333386,uc010whm.2 </TD> </TR>
  <TR> <TD> uc002icp.4 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 854 </TD> <TD> BRCA1,NR_027676,P38398-2,RNF53,uc002icp.4 </TD> </TR>
  <TR> <TD> uc002icu.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,NM_007299,NP_009230,P38398-6,RNF53,uc002icu.3 </TD> </TR>
  <TR> <TD> uc010cyx.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyx.3 </TD> </TR>
  <TR> <TD> uc002ict.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,J3KQF3,J3KQF3_HUMAN,NM_007300,NP_009231,uc002ict.3 </TD> </TR>
  <TR> <TD> uc010whn.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,DQ363751,G3XAC3,G3XAC3_HUMAN,NM_007298,NP_009229,hCG_16943,uc010whn.2 </TD> </TR>
  <TR> <TD> uc010who.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,C6YB46,C6YB46_HUMAN,DQ333387,uc010who.2,uc010who.3 </TD> </TR>
  <TR> <TD> uc002icq.3 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 859 </TD> <TD> BRCA1,BRCA1_HUMAN,NM_007294,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002icq.3 </TD> </TR>
  <TR> <TD> uc010whp.2 </TD> <TD> 17 </TD> <TD align="right"> 41196363 </TD> <TD align="right"> 41322380 </TD> <TD align="right"> 41196311 </TD> <TD align="right"> 41322420 </TD> <TD align="right"> 1383 </TD> <TD> AK293762,B4DES0,B4DES0_HUMAN,BRCA1,NM_007298,NP_009229,uc010whp.2 </TD> </TR>
  <TR> <TD> uc010whq.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41256877 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41256973 </TD> <TD align="right"> 464 </TD> <TD> BC046142,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whq.1 </TD> </TR>
  <TR> <TD> uc002idc.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 674 </TD> <TD> BC085615,BRCA1,E7EUM2,E7EUM2_HUMAN,NM_007299,NP_009230,uc002idc.1 </TD> </TR>
  <TR> <TD> uc010whr.1 </TD> <TD> 17 </TD> <TD align="right"> 41215368 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41215349 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 674 </TD> <TD> AK316200,BRCA1,NM_007299,NP_009230,P38398-3,RNF53,uc010whr.1 </TD> </TR>
  <TR> <TD> uc002idd.3 </TD> <TD> 17 </TD> <TD align="right"> 41243190 </TD> <TD align="right"> 41276093 </TD> <TD align="right"> 41243116 </TD> <TD align="right"> 41276132 </TD> <TD align="right"> 359 </TD> <TD> AY354539,BRCA1,NM_007294,NP_009225,Q5YLB2,Q5YLB2_HUMAN,uc002idd.3 </TD> </TR>
  <TR> <TD> uc002ide.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41256877 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41256973 </TD> <TD align="right"> 167 </TD> <TD> BC038947,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc002ide.1 </TD> </TR>
  <TR> <TD> uc010cyy.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277187 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277340 </TD> <TD align="right"> 372 </TD> <TD> AK308084,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyy.1 </TD> </TR>
  <TR> <TD> uc010whs.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277468 </TD> <TD align="right"> 377 </TD> <TD> BC114562,BRCA1,BRCA1_HUMAN,NM_007294,NP_009225,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010whs.1 </TD> </TR>
  <TR> <TD> uc010cyz.2 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> BC114511,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cyz.2 </TD> </TR>
  <TR> <TD> uc010cza.2 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> AK307553,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010cza.2 </TD> </TR>
  <TR> <TD> uc010wht.1 </TD> <TD> 17 </TD> <TD align="right"> 41243509 </TD> <TD align="right"> 41277460 </TD> <TD align="right"> 41243451 </TD> <TD align="right"> 41277500 </TD> <TD align="right"> 377 </TD> <TD> BC106746,BRCA1,BRCA1_HUMAN,NM_007297,NP_009228,O15129,P38398,Q3LRJ0,Q3LRJ6,Q6IN79,Q7KYU9,RNF53,uc010wht.1 </TD> </TR>
  <TR> <TD> uc001cvi.2 </TD> <TD> 1 </TD> <TD align="right"> 53708043 </TD> <TD align="right"> 53793511 </TD> <TD align="right"> 53708040 </TD> <TD align="right"> 53793821 </TD> <TD align="right"> 1053 </TD> <TD> APOER2,B1AMT6,B1AMT7,B1AMT8,LRP8,LRP8_HUMAN,NM_004631,NP_004622,O14968,Q14114,Q86V27,Q99876,Q9BR78,uc001cvi.2 </TD> </TR>
  <TR> <TD> uc001cvj.2 </TD> <TD> 1 </TD> <TD align="right"> 53708043 </TD> <TD align="right"> 53793511 </TD> <TD align="right"> 53708040 </TD> <TD align="right"> 53793821 </TD> <TD align="right"> 1053 </TD> <TD> APOER2,LRP8,NM_001018054,NP_001018064,Q14114-3,uc001cvj.2 </TD> </TR>
  <TR> <TD> uc001cvk.2 </TD> <TD> 1 </TD> <TD align="right"> 53708043 </TD> <TD align="right"> 53793511 </TD> <TD align="right"> 53708040 </TD> <TD align="right"> 53793821 </TD> <TD align="right"> 1053 </TD> <TD> APOER2,LRP8,NM_033300,NP_150643,Q14114-4,uc001cvk.2 </TD> </TR>
  <TR> <TD> uc001cvl.2 </TD> <TD> 1 </TD> <TD align="right"> 53708043 </TD> <TD align="right"> 53793511 </TD> <TD align="right"> 53708040 </TD> <TD align="right"> 53793821 </TD> <TD align="right"> 1053 </TD> <TD> APOER2,LRP8,NM_017522,NP_059992,Q14114-2,uc001cvl.2 </TD> </TR>
  <TR> <TD> uc001cvm.1 </TD> <TD> 1 </TD> <TD align="right"> 53716416 </TD> <TD align="right"> 53734102 </TD> <TD align="right"> 53716361 </TD> <TD align="right"> 53734270 </TD> <TD align="right"> 192 </TD> <TD> AK122887,APOER2,LRP8,NM_033300,NP_150643,Q14114-4,uc001cvm.1 </TD> </TR>
  <TR> <TD> uc002pab.3 </TD> <TD> 19 </TD> <TD align="right"> 45409113 </TD> <TD align="right"> 45412420 </TD> <TD align="right"> 45409038 </TD> <TD align="right"> 45412650 </TD> <TD align="right">  36 </TD> <TD> APOE,APOE_HUMAN,B2RC15,C0JYY5,NM_000041,NP_000032,P02649,Q9P2S4,uc002pab.3 </TD> </TR>
   </TABLE>

And we sum the count of variants in this entire dataset found within the genes corresponding to BRCA1 and APOE.
## JOINs that find the nearest interval

We can use table-valued functions to do a sub-select on our annotation tables and emit three rows per interval
 1. the interval prior to the region, e.g. {start=geneStart - threshold, end=geneStart-1, type=3primeEndIntergenic}
 1. the interval for the region, e.g. {start=geneStart - threshold, end=geneStart-1, type=intragenic}
 1. the interval after to the region, e.g. {start=geneEnd + 1, end=geneEnd + threshold, type=3primeEndIntergenic}

Example: TBD

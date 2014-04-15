Understanding Alternate Alleles in 1,000 Genomes VCF Data
========================================================

We know from the [FAQ](http://www.1000genomes.org/faq/are-all-genotype-calls-current-release-vcf-files-bi-allelic) that the 1,000 Genomes VCF data is [bi-allelic](http://www.1000genomes.org/faq/are-all-genotype-calls-current-release-vcf-files-bi-allelic) → meaning that each row in the source VCF has only one value in the ALT field.  So for each sample in a row, the genotype was called as either the reference or the single ALT value.  At any particular position in the genome we can have much more variation than a single alternate, so we need to understand how that is encoded in this data set.

_Let’s explore the question “Is (contig, position, reference_bases) a unique key in the 1,000 Genomes Data?”_


```
SELECT
  contig,
  position,
  reference_bases,
  COUNT(position) AS num_alternates
FROM
  [google.com:biggene:1000genomes.variants1kG]
WHERE
  contig = '17'
GROUP BY
  contig,
  position,
  reference_bases
HAVING
  num_alternates > 1
ORDER BY
  contig,
  position,
  reference_bases;
```


Number of rows in result: 417 


We see the first six tabular results:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 14 18:58:57 2014 -->
<TABLE border=1>
<TR> <TH> contig </TH> <TH> position </TH> <TH> reference_bases </TH> <TH> num_alternates </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 184673 </TD> <TD> G </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 211032 </TD> <TD> C </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 240040 </TD> <TD> G </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 443436 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 533536 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 557991 </TD> <TD> A </TD> <TD align="right">   2 </TD> </TR>
   </TABLE>


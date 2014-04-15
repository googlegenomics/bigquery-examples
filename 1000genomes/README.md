genomics-bigquery 1,000 Genomes
=================

### Additional Resources
* Schema
* [Provenance](./provenance)
* [Data Stories](./data-stories)
 * [Exploring the phenotypic data](./data-stories/exploring-the-phenotypic-data)
 * [Understanding Alternate Alleles in 1,000 Genomes](./data-stories/understanding-alternate-alleles)
 * [Reproducing the output of vcfstats](./data-stories/reproducing-vcfstats)
 * [Examining the clinical significance of variants](./data-stories/examining-clinical-significance)
 * [Literate Programming with R and BigQuery](./data-stories/literate-programming-demo)
* Index of variant analyses

### Diving right in

The following query returns the proportion of variants that have been reported in the [dbSNP database](http://www.ncbi.nlm.nih.gov/projects/SNP/snp_summary.cgi?build_id=132) [version 132](http://www.1000genomes.org/category/variants), by chromosome, in the dataset:


```
SELECT
  variants.contig,
  variants.num_variants,
  total.num_entries,
  variants.num_variants / total.num_entries freq
FROM (
  SELECT
    contig,
    COUNT(*) num_variants
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  WHERE
    id IS NOT NULL
  GROUP BY
    contig) variants
JOIN (
  SELECT
    contig,
    COUNT(*) num_entries
  FROM
    [google.com:biggene:1000genomes.variants1kG]
  GROUP BY
    contig
    ) total
  ON variants.contig = total.contig
ORDER BY
  total.num_entries DESC;
```


We see the tabular results:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 14 19:30:40 2014 -->
<TABLE border=1>
<TR> <TH> variants_contig </TH> <TH> variants_num_variants </TH> <TH> total_num_entries </TH> <TH> freq </TH>  </TR>
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
   </TABLE>


And visually:
<img src="figure/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


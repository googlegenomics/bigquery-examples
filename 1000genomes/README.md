genomics-bigquery 1,000 Genomes
=================

### Additional Resources
* Schema
* [Provenance](./provenance)
* [Data Stories](./data-stories)
 * [Understanding Alternate Alleles in 1,000 Genomes](understanding-alternate-alleles)
 * Reproducing the output of vcfstats
 * Examining the clinical significance of variants
 * [Literate Programming with R and BigQuery](./literate-programming-demo)
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


We see tabular results:

```
   variants_contig variants_num_variants total_num_entries   freq
1                2               3301885           3307592 0.9983
2                1               3001739           3007196 0.9982
3                3               2758667           2763454 0.9983
4                4               2731973           2736765 0.9982
5                5               2525874           2530217 0.9983
6                6               2420027           2424425 0.9982
7                7               2211317           2215231 0.9982
8                8               2180311           2183839 0.9984
9               11               1891627           1894908 0.9983
10              10               1879337           1882663 0.9982
11              12               1824513           1828006 0.9981
12               9               1649563           1652388 0.9983
13               X               1482078           1487477 0.9964
14              13               1370342           1373000 0.9981
15              14               1255966           1258254 0.9982
16              16               1208679           1210619 0.9984
17              15               1128457           1130554 0.9981
18              18               1086823           1088820 0.9982
19              17               1044658           1046733 0.9980
20              20                853680            855166 0.9983
21              19                814343            816115 0.9978
22              21                517920            518965 0.9980
23              22                493717            494328 0.9988
```


And visually:
<img src="figure/unnamed-chunk-3.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />


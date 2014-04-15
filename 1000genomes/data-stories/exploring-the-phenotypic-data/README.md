Exploring the phenotypic data
========================================================

Note that the full 1,000 dataset has data for 3,500 individuals but the variants in table variants1kG are only for a subset of those individuals.  Let’s explore the phenotypic traits for the individuals whose variant data we do have.




How many sample are we working with in this variant dataset?

```
SELECT
  COUNT(sample)AS cnt
FROM
  [google.com:biggene:1000genomes.sample_info]
WHERE
  In_Phase1_Integrated_Variant_Set = TRUE;
```


<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 14 19:18:01 2014 -->
<TABLE border=1>
<TR> <TH> cnt </TH>  </TR>
  <TR> <TD align="right"> 1092 </TD> </TR>
   </TABLE>

So for analyses across all samples, the sample size is 1,092.

What is the gender ratio?

```
SELECT
  gender,
  gender_count,
  RATIO_TO_REPORT(gender_count)
OVER
  (
  ORDER BY
    gender_count) AS gender_ratio
from(
  SELECT
    gender,
    COUNT(gender) AS gender_count,
  FROM
    [google.com:biggene:1000genomes.sample_info]
  WHERE
    In_Phase1_Integrated_Variant_Set = TRUE
  GROUP BY
    gender);
```



<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Mon Apr 14 19:18:06 2014 -->
<TABLE border=1>
<TR> <TH> gender </TH> <TH> gender_count </TH> <TH> gender_ratio </TH>  </TR>
  <TR> <TD> male </TD> <TD align="right"> 525 </TD> <TD align="right"> 0.48 </TD> </TR>
  <TR> <TD> female </TD> <TD align="right"> 567 </TD> <TD align="right"> 0.52 </TD> </TR>
   </TABLE>

So for analyses across genders the sample size is roughly even.

What are the ratios of ethnicities?



Number of rows in result: 2 



TODO(deflaux): more here

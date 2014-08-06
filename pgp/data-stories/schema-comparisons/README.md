<!-- R Markdown Documentation, DO NOT EDIT THE PLAIN MARKDOWN VERSION OF THIS FILE -->

<!-- Licensed under the Apache License, Version 2.0 (the "License"); -->
<!-- you may not use this file except in compliance with the License. -->
<!-- You may obtain a copy of the License at -->

<!--     http://www.apache.org/licenses/LICENSE-2.0 -->

<!-- Unless required by applicable law or agreed to in writing, software -->
<!-- distributed under the License is distributed on an "AS IS" BASIS, -->
<!-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. -->
<!-- See the License for the specific language governing permissions and -->
<!-- limitations under the License. -->

A Comparison of Schemas and Data Encodings
========================================




To determine how to improve the usability of the data and the schemas, we have the same data encoded several different ways, to compare and contrast querying each.

Table      | Table Size | Description 
:------------- |:---------------:|:---------------
[cgi_variants](../../provenance#cgi_variants-table)  |433GB | data from 174 CGI masterVar files in a flat schema (one row per sample) with reference matching blocks
[gvcf_variants](../../provenance#gvcf_variants-table)  | 231GB | CGI data for 172 individuals converted to gVCF in a nested schema (per-sample data is nested) with reference matching blocks
[gvcf_variants_expanded](../../provenance#gvcf_variants_expanded-table)  |506GB| CGI data for 172 individuals converted to gVCF in a nested schema (per-sample data is nested) with reference matching blocks further transformed to have all data for a particular variant within one record (added 0/0 genotypes for samples that match the reference at the variant position)




### Sample-level data for a particular variant
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/klotho.sql">klotho.sql</a> </TD> <TD> 4.1s elapsed </TD> <TD> 117 GB processed </TD> <TD> 18 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/klotho.sql">klotho.sql</a> </TD> <TD> 5.3s elapsed </TD> <TD> 76.0 GB processed </TD> <TD> 35 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants_expanded-table">gvcf_variants_expanded</a> </TD> <TD> <a href="../../sql/gvcf_variants_expanded/klotho.sql">klotho.sql</a> </TD> <TD> 7.7s elapsed </TD> <TD> 196 GB processed </TD> <TD> 32 </TD> <TD>  </TD> </TR>
   </TABLE>


### Per-sample Ti/Tv Ratio
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/ti-tv-ratio.sql">ti-tv-ratio.sql</a> </TD> <TD> 3.8s elapsed </TD> <TD> 53.7 GB processed </TD> <TD> 60 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/ti-tv-ratio.sql">ti-tv-ratio.sql</a> </TD> <TD> 29.3s elapsed </TD> <TD> 59.2 GB processed </TD> <TD> 63 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants_expanded-table">gvcf_variants_expanded</a> </TD> <TD> <a href="../../sql/gvcf_variants_expanded/ti-tv-ratio.sql">ti-tv-ratio.sql</a> </TD> <TD> 83.5s elapsed </TD> <TD> 185 GB processed </TD> <TD> 64 </TD> <TD>  </TD> </TR>
   </TABLE>


### Allelic Frequency for a small region
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/allelic-frequency-brca1.sql">allelic-frequency-brca1.sql</a> </TD> <TD> 83.4s elapsed </TD> <TD> 117 GB processed </TD> <TD> 159 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/allelic-frequency-brca1.sql">allelic-frequency-brca1.sql</a> </TD> <TD> 171.8s elapsed </TD> <TD> 53.3 GB processed </TD> <TD> 143 </TD> <TD>  </TD> </TR>
   </TABLE>


### Allele counts for the full dataset
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/allele-count.sql">allele-count.sql</a> </TD> <TD> 70.2s elapsed
 </TD> <TD> 88.8 GB processed

 </TD> <TD> 59 </TD> <TD> result materialized to table google.com:biggene:pgp_analysis_results.cgi_variants_allele_counts </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/allele-count.sql">allele-count.sql</a> </TD> <TD> 146.1s elapsed </TD> <TD> 43.6 GB processed </TD> <TD> 48 </TD> <TD> result materialized to table google.com:biggene:pgp_analysis_results.gvcf_variants_allele_counts </TD> </TR>
   </TABLE>


### Allelic Frequency for a large region
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/allelic-frequency-chr1.sql">allelic-frequency-chr1.sql</a> </TD> <TD> 85.3s elapsed </TD> <TD> 90.4 GB processed </TD> <TD> 93 </TD> <TD> results for all chromosomes materialized to table google.com:biggene:pgp_analysis_results.cgi_variants_allelic_frequency </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/allelic-frequency-chr1.sql">allelic-frequency-chr1.sql</a> </TD> <TD> 196.2s elapsed </TD> <TD> 54.6 GB processed </TD> <TD> 96 </TD> <TD> results for all chromosomes materialized to table google.com:biggene:pgp_analysis_results.gvcf_variants_allelic_frequency </TD> </TR>
   </TABLE>


### Allelic Frequency for the full dataset
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants_expanded-table">gvcf_variants_expanded</a> </TD> <TD> <a href="../../sql/gvcf_variants_expanded/allelic-frequency.sql">allelic-frequency.sql</a> </TD> <TD> 318.7s elapsed </TD> <TD> 121 GB processed </TD> <TD> 68 </TD> <TD> the pattern is correct but the result will be wrong until records for "the same" variant are merged together </TD> </TR>
   </TABLE>


### Allelic Frequency compared to that of 1,000 Genomes
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:15 2014 -->
<TABLE border=1>
<TR> <TH> table_link </TH> <TH> code_link </TH> <TH> runtime </TH> <TH> data_processed </TH> <TH> line_count </TH> <TH> notes </TH>  </TR>
  <TR> <TD> <a href="../../provenance#cgi_variants-table">cgi_variants</a> </TD> <TD> <a href="../../sql/cgi_variants/allelic-frequency-comparison.sql">allelic-frequency-comparison.sql</a> </TD> <TD> 69.3s elapsed </TD> <TD> 2.83 GB processed </TD> <TD> 38 </TD> <TD>  </TD> </TR>
  <TR> <TD> <a href="../../provenance#gvcf_variants-table">gvcf_variants</a> </TD> <TD> <a href="../../sql/gvcf_variants/allelic-frequency-comparison.sql">allelic-frequency-comparison.sql</a> </TD> <TD> 47.2s elapsed </TD> <TD> 2.71 GB processed </TD> <TD> 33 </TD> <TD>  </TD> </TR>
   </TABLE>


_The sizes and timings represent an arbitrary point in time.  More data may be added to these tables over time and the timings are expected to be noticeably variable.  See also [#11](https://github.com/googlegenomics/bigquery-examples/issues/11), [#12](https://github.com/googlegenomics/bigquery-examples/issues/12), and [#15](https://github.com/googlegenomics/bigquery-examples/issues/15)_

Motivation
-----------------

We wrote many, many [queries for 1,000 Genomes](../../../1000genomes/sql) and they were relatively straightforward since all the data for all samples for a particular variant could be found on a single row in the table.

For subsequent work with data encoded as [gVCF](https://sites.google.com/site/gvcftools/home/about-gvcf/gvcf-conventions), the queries were much more challenging.  With gVCF data we have *reference-matching block records*, so our SQL statements need to determine which samples have reference-matching regions that overlap the variant(s) in which we are interested.

This is pretty straightforward for individual variants.  For example for a particular variant in the [Klotho gene](http://www.snpedia.com/index.php/Rs9536314) discussed in [this data story](../issues-with-the-variant-centric-approach#thomas-confirms-amazing-intelligence-in-the-pgp-cohort) the `WHERE` clause
```
    WHERE
      contig_name = '13'
      AND start_pos == 33628138
```
becomes
```
    WHERE
      contig_name = '13'
      AND start_pos <= 33628138
      AND (end_pos >= 33628139
        OR END >= 33628139)
```
to capture not only that variant, but any other records that overlap that genomic position.  Suppose we want to calculate an aggregate for a particular variant, such as the number of samples with the variant on one or both alleles and of samples that match the reference.


```
# Missingness rate for Klotho variant rs9536314 in the "amazing
# intelligence of PGP participants" data story.
SELECT
  COUNT(sample_id) AS num_samples_called_for_position,
  SUM(called_count) AS num_alleles_called_for_position,
  1 - (SUM(called_count)/(172*2)) AS missingness_rate
FROM (
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    reference_bases,
    GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
    call.callset_name AS sample_id,
    GROUP_CONCAT(STRING(call.genotype),
      '/') WITHIN call AS genotype,
    SUM(call.genotype >= 0) WITHIN RECORD as called_count,
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  WHERE
    contig_name = '13'
    AND start_pos <= 33628138
    AND (end_pos = 33628139
      OR END >= 33628139)
    )
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:23 2014 -->
<TABLE border=1>
<TR> <TH> num_samples_called_for_position </TH> <TH> num_alleles_called_for_position </TH> <TH> missingness_rate </TH>  </TR>
  <TR> <TD align="right">     170 </TD> <TD align="right">     340 </TD> <TD align="right"> 0.011628 </TD> </TR>
   </TABLE>


This works fine for a single variant, but what if we want to compute missingness for a gene, a chromosome, or our whole dataset?

```
# Missingness rate for variants within BRCA1.
SELECT
  vars.contig_name AS contig_name,
  vars.start_pos AS start_pos,
  reference_bases,
  variant_called_count,
  SUM(refs.called_count) AS reference_called_count,
  variant_called_count + SUM(refs.called_count) AS num_alleles_called_for_position,
  1 - ((variant_called_count + SUM(refs.called_count))/(172*2)) AS missingness_rate
FROM (
  # _JOIN our variant sample counts with the corresponding reference-matching blocks
  SELECT
    vars.contig_name,
    vars.start_pos,
    refs.start_pos,
    vars.end_pos,
    refs.END,
    reference_bases,
    variant_called_count,
    refs.called_count
  FROM (
    # Constrain the left hand side of the _JOIN to reference-matching blocks
    SELECT
      contig_name,
      start_pos,
      END,
      IF(alternate_bases IS NULL,
        FALSE,
        TRUE) AS is_variant_call,
      SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants]
    WHERE
      contig_name = '17'
    HAVING
      is_variant_call = FALSE) AS refs
  JOIN (
    # Constrain the right hand side of the _JOIN to variants
    # _GROUP our variant sample counts together since a single SNP may be IN more than
    # one row due 1 / 2 genotypes
    SELECT
      contig_name,
      start_pos,
      end_pos,
      reference_bases,
      SUM(called_count) AS variant_called_count,
    FROM (
        # _LIMIT the query to SNPs _ON chromosome 17 WITHIN BRCA1
      SELECT
        contig_name,
        start_pos,
        end_pos,
        reference_bases,
        LENGTH(reference_bases) AS ref_len,
        MIN(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
        IF(alternate_bases IS NULL,
          FALSE,
          TRUE) AS is_variant_call,
        SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
      FROM
        [google.com:biggene:test.pgp_gvcf_variants]
      WHERE
        contig_name = '17'
        AND start_pos BETWEEN 41196312
        AND 41277500
      HAVING
        ref_len = 1
        AND alt_len = 1
        AND is_variant_call)
    GROUP BY
      contig_name,
      start_pos,
      end_pos,
      reference_bases) AS vars
  # The _JOIN criteria IS complicated since we are trying to see if a SNP overlaps an interval
  ON
    vars.contig_name = refs.contig_name
  WHERE
    refs.start_pos <= vars.start_pos
    AND refs.END >= vars.end_pos
    )
GROUP BY
  contig_name,
  start_pos,
  reference_bases,
  variant_called_count
```

Number of rows returned by this query: 540.

Examing the first few rows, we see:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:28 2014 -->
<TABLE border=1>
<TR> <TH> contig_name </TH> <TH> start_pos </TH> <TH> reference_bases </TH> <TH> variant_called_count </TH> <TH> reference_called_count </TH> <TH> num_alleles_called_for_position </TH> <TH> missingness_rate </TH>  </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41211927 </TD> <TD> T </TD> <TD align="right">       2 </TD> <TD align="right">     302 </TD> <TD align="right">     304 </TD> <TD align="right"> 0.116279 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41212649 </TD> <TD> A </TD> <TD align="right">       2 </TD> <TD align="right">     340 </TD> <TD align="right">     342 </TD> <TD align="right"> 0.005814 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41211681 </TD> <TD> A </TD> <TD align="right">       2 </TD> <TD align="right">     342 </TD> <TD align="right">     344 </TD> <TD align="right"> 0.000000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41212547 </TD> <TD> C </TD> <TD align="right">     202 </TD> <TD align="right">     142 </TD> <TD align="right">     344 </TD> <TD align="right"> 0.000000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41211653 </TD> <TD> A </TD> <TD align="right">     202 </TD> <TD align="right">     142 </TD> <TD align="right">     344 </TD> <TD align="right"> 0.000000 </TD> </TR>
  <TR> <TD> 17 </TD> <TD align="right"> 41213626 </TD> <TD> G </TD> <TD align="right">     192 </TD> <TD align="right">     142 </TD> <TD align="right">     334 </TD> <TD align="right"> 0.029070 </TD> </TR>
   </TABLE>


The query above works fine for a small region of the genome, but it becomes prohibitive when running it against a larger region due to the size of the cross product found in the ON clause (checking for equality on chromosome) subsequently whitled down via the WHERE clause (confirming that the records overlap).

To further reduce the size of the cross product, we can make use of the new User-Defined Function feature of BigQuery to dynamically add additional criteria for use in the ON clause, namely the genome "bin(s)" in which the reference-matching blocks reside.


```
# Missingness rate summarized per chromosome.  To see it per variant, materialize 
# the large result from the inner query to a table.
SELECT
  contig_name,
  MIN(missingness_rate) AS min_missingness,
  AVG(missingness_rate) AS avg_missingness,
  MAX(missingness_rate) AS max_missingness,
  STDDEV(missingness_rate) AS stddev_missingness,
FROM (
  SELECT
    vars.contig_name AS contig_name,
    vars.start_pos AS start_pos,
    reference_bases,
    variant_called_count,
    SUM(refs.called_count) AS reference_called_count,
    variant_called_count + SUM(refs.called_count) AS num_alleles_called_for_position,
    1 - ((variant_called_count + SUM(refs.called_count))/(172*2)) AS missingness_rate
  FROM (
    # _JOIN our variant sample counts with the corresponding reference-matching blocks
    SELECT
      vars.contig_name,
      vars.start_pos,
      refs.start_pos,
      vars.end_pos,
      refs.the_end,
      reference_bases,
      variant_called_count,
      refs.called_count
    FROM js(
      # Constrain the left hand side of the _JOIN to reference-matching blocks
      (SELECT
         contig_name,
         start_pos,
         END,
         IF(alternate_bases IS NULL,
           FALSE,
           TRUE) AS is_variant_call,
         SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
       FROM
         [google.com:biggene:test.pgp_gvcf_variants]
       HAVING
         is_variant_call = FALSE),
      contig_name, start_pos, END, called_count,
      # This User-defined function helps us reduce the size of the cross product
      # considered by this JOIN thereby greatly speeding up the query.
      "[{name: 'contig_name', type: 'string'},
        {name: 'start_pos', type: 'integer'},
        {name: 'the_end', type: 'integer'},
        {name: 'bin', type: 'integer'},
        {name: 'called_count', type: 'integer'}]",
       "function(r, emit) {
            var binSize = 5000
            var startBin = Math.floor(r.start_pos / binSize);
            var endBin = Math.floor(r.END / binSize);
            // Since a reference-matching block can span multiple bins, emit
            // a record for each bin.
            for(var bin = startBin; bin <= endBin; bin++) {
              emit({
                contig_name: r.contig_name,
                start_pos: r.start_pos,
                the_end: r.END,
                bin: bin,
                called_count: r.called_count
              });
            }
        }") AS refs
    JOIN EACH (
      # Constrain the right hand side of the _JOIN to variants
      # _GROUP our variant sample counts together since a single SNP may be IN more than
      # one row due 1 / 2 genotypes
      SELECT
        contig_name,
        start_pos,
        end_pos,
        INTEGER(FLOOR(start_pos / 5000)) AS bin,
        reference_bases,
        SUM(called_count) AS variant_called_count,
      FROM (
        # _LIMIT the query to SNPs
        SELECT
          contig_name,
          start_pos,
          end_pos,
          reference_bases,
          LENGTH(reference_bases) AS ref_len,
          MIN(LENGTH(alternate_bases)) WITHIN RECORD AS alt_len,
          IF(alternate_bases IS NULL,
            FALSE,
            TRUE) AS is_variant_call,
          SUM(call.genotype >= 0) WITHIN RECORD AS called_count,
        FROM
          [google.com:biggene:test.pgp_gvcf_variants]
        HAVING
          ref_len = 1
          AND alt_len = 1
          AND is_variant_call)
      GROUP EACH BY
        contig_name,
        start_pos,
        end_pos,
        bin,
        reference_bases) AS vars
    # The _JOIN criteria IS complicated since we are trying to see if a SNP overlaps an interval
    ON
      vars.contig_name = refs.contig_name
      AND vars.bin = refs.bin
    WHERE
      refs.start_pos <= vars.start_pos
      AND refs.the_end >= vars.end_pos
      )
  GROUP EACH BY
    contig_name,
    start_pos,
    reference_bases,
    variant_called_count
    )
GROUP BY
  contig_name
ORDER BY
  contig_nameRunning query:   RUNNING  2.3sRunning query:   RUNNING  2.9sRunning query:   RUNNING  3.8sRunning query:   RUNNING  4.4sRunning query:   RUNNING  5.6sRunning query:   RUNNING  6.7sRunning query:   RUNNING  7.7sRunning query:   RUNNING  8.3sRunning query:   RUNNING  9.2sRunning query:   RUNNING 10.3sRunning query:   RUNNING 10.9sRunning query:   RUNNING 12.0sRunning query:   RUNNING 12.7sRunning query:   RUNNING 13.5sRunning query:   RUNNING 14.6sRunning query:   RUNNING 15.7sRunning query:   RUNNING 16.5sRunning query:   RUNNING 17.4sRunning query:   RUNNING 18.5sRunning query:   RUNNING 19.5s
```

Number of rows returned by this query: 23.

Examing the first few rows, we see:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:54 2014 -->
<TABLE border=1>
<TR> <TH> contig_name </TH> <TH> min_missingness </TH> <TH> avg_missingness </TH> <TH> max_missingness </TH> <TH> stddev_missingness </TH>  </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.068160 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.178460 </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.066211 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.179023 </TD> </TR>
  <TR> <TD> 11 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.079723 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.196867 </TD> </TR>
  <TR> <TD> 12 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.073314 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.185816 </TD> </TR>
  <TR> <TD> 13 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.068605 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.170226 </TD> </TR>
  <TR> <TD> 14 </TD> <TD align="right"> 0.000000 </TD> <TD align="right"> 0.069970 </TD> <TD align="right"> 0.991279 </TD> <TD align="right"> 0.180348 </TD> </TR>
   </TABLE>


Appendix
==========================
Some queries to help check that the four versions of the data were correctly transformed.

Check Record Counts
---------------------


```
# Call counts for the PGP data encoded four different ways.
SELECT
  chromosome,
  num_records,
  num_variants,
  dataset
FROM
  (
  SELECT
    SUBSTR(chromosome,
      4) AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference != '=') AS num_variants,
    'cgi_variants' AS dataset
  FROM
    [google.com:biggene:pgp.cgi_variants]
  # Skip the genomes we were unable to convert to VCF/gVCF
  OMIT RECORD IF 
    sample_id = 'huEDF7DA' OR sample_id = 'hu34D5B9'
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'variants' AS dataset
  FROM
    [google.com:biggene:pgp.variants]
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'gvcf_variants' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants]
  GROUP BY
    chromosome),
  (
  SELECT
    contig_name AS chromosome,
    COUNT(1) AS num_records,
    SUM(reference_bases != 'N') AS num_variants,
    'gvcf_variants_expanded' AS dataset
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded2]
  GROUP BY
    chromosome)
ORDER BY
  chromosome,
  dataset
```

Number of rows returned by this query: 100.

Examing the first few rows, we see:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:07:59 2014 -->
<TABLE border=1>
<TR> <TH> chromosome </TH> <TH> num_records </TH> <TH> num_variants </TH> <TH> dataset </TH>  </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 238124699 </TD> <TD align="right"> 52490861 </TD> <TD> cgi_variants </TD> </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 52200100 </TD> <TD align="right"> 3349506 </TD> <TD> gvcf_variants </TD> </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 52200100 </TD> <TD align="right"> 3349506 </TD> <TD> gvcf_variants_expanded </TD> </TR>
  <TR> <TD> 1 </TD> <TD align="right"> 3349506 </TD> <TD align="right"> 3349506 </TD> <TD> variants </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 139345544 </TD> <TD align="right"> 33649415 </TD> <TD> cgi_variants </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 29709727 </TD> <TD align="right"> 2093519 </TD> <TD> gvcf_variants </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 29709727 </TD> <TD align="right"> 2093519 </TD> <TD> gvcf_variants_expanded </TD> </TR>
  <TR> <TD> 10 </TD> <TD align="right"> 2093521 </TD> <TD align="right"> 2093519 </TD> <TD> variants </TD> </TR>
   </TABLE>


And visually:
<img src="figure/variant_cnt.png" title="plot of chunk variant_cnt" alt="plot of chunk variant_cnt" style="display: block; margin: auto;" />

<img src="figure/call_cnt.png" title="plot of chunk call_cnt" alt="plot of chunk call_cnt" style="display: block; margin: auto;" />


Let's also confirm with a few tests:

```r
cgi_variants <- filter(result, dataset == "cgi_variants")
variants <- filter(result, dataset == "variants")
gvcf_variants <- filter(result, dataset == "gvcf_variants")
gvcf_variants_expanded <- filter(result, dataset == "gvcf_variants_expanded")
```

cgi_variants will have many, many more rows than the other tables because it is completely flat (one row per sample):

```r
print(expect_that(unique(cgi_variants$num_records > variants$num_records), is_true()))
```

```
## As expected: unique(cgi_variants$num_records > variants$num_records) is true
```

```r
print(expect_that(unique(cgi_variants$num_records > gvcf_variants$num_records), 
    is_true()))
```

```
## As expected: unique(cgi_variants$num_records > gvcf_variants$num_records) is true
```

```r
print(expect_that(unique(cgi_variants$num_records > gvcf_variants_expanded$num_records), 
    is_true()))
```

```
## As expected: unique(cgi_variants$num_records > gvcf_variants_expanded$num_records) is true
```

All tables derived from VCF/gVCF data will have the same number of variant records:

```r
print(expect_equal(variants$num_variants, gvcf_variants$num_variants))
```

```
## As expected: variants$num_variants equals gvcf_variants$num_variants
```

```r
print(expect_equal(variants$num_variants, gvcf_variants_expanded$num_variants))
```

```
## As expected: variants$num_variants equals gvcf_variants_expanded$num_variants
```

The variants table has almost no additional records (just a handful of no-call records):

```r
print(expect_equal(variants$num_records, variants$num_variants, tolerance = 1e-06))
```

```
## As expected: variants$num_records equals variants$num_variants
```




Both the gvcf_variants and gvcf_variants_expanded tables have additional records (reference-matching block records).  TODO(deflaux): [#11](https://github.com/googlegenomics/bigquery-examples/issues/11) the counts are equal for Y and M, fix the bug in cgi-ref-blocks-mapper.py and re-run it.

```r
print(expect_that(unique(gvcf_variants$num_records >= variants$num_records), 
    is_true()))
```

```
## As expected: unique(gvcf_variants$num_records >= variants$num_records) is true
```

```r
print(expect_that(unique(gvcf_variants_expanded$num_records >= variants$num_records), 
    is_true()))
```

```
## As expected: unique(gvcf_variants_expanded$num_records >= variants$num_records) is true
```

The gvcf_variants and gvcf_variants_expanded tables have the same number of records, the difference between the two is in the number of nested sample variant calls.

```r
print(expect_equal(gvcf_variants$num_records, gvcf_variants_expanded$num_records))
```

```
## As expected: gvcf_variants$num_records equals gvcf_variants_expanded$num_records
```



Check Sample Counts
---------------------


```
# Sample call counts for the PGP data encoded several different ways.  
# NOTE: table pgp.variants was left out of this example since its more trouble
# than its worth to parse the GT field into its components. 
SELECT
  sample_id,
  num_records,
  num_variant_alleles,
  dataset
FROM
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(allele1_is_variant + allele2_is_variant)) AS num_variant_alleles,
    'cgi_variants' AS dataset
  FROM (
    SELECT
      sample_id,
      allele1Seq != reference
      AND allele1Seq != '='
      AND allele1Seq != '?' AS allele1_is_variant,
      allele2Seq != reference
      AND allele2Seq != '='
      AND allele2Seq != '?' AS allele2_is_variant,
    FROM
      [google.com:biggene:pgp.cgi_variants]
      # Skip the genomes we were unable to convert to VCF/gVCF
    OMIT
      RECORD IF
      sample_id = 'huEDF7DA'
      OR sample_id = 'hu34D5B9')
  GROUP BY
    sample_id),
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(num_variant_alleles)) AS num_variant_alleles,
    'gvcf_variants' AS dataset
  FROM (
    SELECT
      call.callset_name AS sample_id,
      SUM(call.genotype > 0) WITHIN call AS num_variant_alleles,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants])
  GROUP BY
    sample_id),
  (
  SELECT
    sample_id,
    COUNT(sample_id) AS num_records,
    INTEGER(SUM(num_variant_alleles)) AS num_variant_alleles,
    'gvcf_variants_expanded' AS dataset
  FROM
    (
    SELECT
      call.callset_name AS sample_id,
      SUM(call.genotype > 0) WITHIN call AS num_variant_alleles,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants_expanded])
  GROUP BY
    sample_id)
ORDER BY
  sample_id,
  dataset
```

Number of rows returned by this query: 516.

Examing the first few rows, we see:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:08:05 2014 -->
<TABLE border=1>
<TR> <TH> sample_id </TH> <TH> num_records </TH> <TH> num_variant_alleles </TH> <TH> dataset </TH>  </TR>
  <TR> <TD> hu011C57 </TD> <TD align="right"> 17615409 </TD> <TD align="right"> 4744749 </TD> <TD> cgi_variants </TD> </TR>
  <TR> <TD> hu011C57 </TD> <TD align="right"> 14123577 </TD> <TD align="right"> 5518279 </TD> <TD> gvcf_variants </TD> </TR>
  <TR> <TD> hu011C57 </TD> <TD align="right"> 43988119 </TD> <TD align="right"> 5518279 </TD> <TD> gvcf_variants_expanded </TD> </TR>
  <TR> <TD> hu016B28 </TD> <TD align="right"> 17585284 </TD> <TD align="right"> 4777466 </TD> <TD> cgi_variants </TD> </TR>
  <TR> <TD> hu016B28 </TD> <TD align="right"> 14134088 </TD> <TD align="right"> 5556632 </TD> <TD> gvcf_variants </TD> </TR>
  <TR> <TD> hu016B28 </TD> <TD align="right"> 43933062 </TD> <TD align="right"> 5556632 </TD> <TD> gvcf_variants_expanded </TD> </TR>
  <TR> <TD> hu0211D6 </TD> <TD align="right"> 20148634 </TD> <TD align="right"> 4844626 </TD> <TD> cgi_variants </TD> </TR>
  <TR> <TD> hu0211D6 </TD> <TD align="right"> 15668766 </TD> <TD align="right"> 5462930 </TD> <TD> gvcf_variants </TD> </TR>
   </TABLE>


And visually:
<img src="figure/sample_variant_cnt.png" title="plot of chunk sample_variant_cnt" alt="plot of chunk sample_variant_cnt" style="display: block; margin: auto;" />


<img src="figure/sample_call_cnt.png" title="plot of chunk sample_call_cnt" alt="plot of chunk sample_call_cnt" style="display: block; margin: auto;" />



Let's also confirm with a few tests:

```r
cgi_variants <- filter(result, dataset == "cgi_variants")
gvcf_variants <- filter(result, dataset == "gvcf_variants")
gvcf_variants_expanded <- filter(result, dataset == "gvcf_variants_expanded")
```

The tables have data for all the same samples:

```r
print(expect_equal(length(cgi_variants$sample_id), 172))
```

```
## As expected: length(cgi_variants$sample_id) equals 172
```

```r
print(expect_equal(cgi_variants$sample_id, gvcf_variants$sample_id))
```

```
## As expected: cgi_variants$sample_id equals gvcf_variants$sample_id
```

```r
print(expect_equal(cgi_variants$sample_id, gvcf_variants_expanded$sample_id))
```

```
## As expected: cgi_variants$sample_id equals gvcf_variants_expanded$sample_id
```

Make sure we correctly expanded the reference-matching calls into the variant records:

```r
print(expect_equal(gvcf_variants$num_variant_alleles, gvcf_variants_expanded$num_variant_alleles))
```

```
## As expected: gvcf_variants$num_variant_alleles equals gvcf_variants_expanded$num_variant_alleles
```

The cgi_variants table actually has fewer variant alleles per sample.  TODO(deflaux): [#12](https://github.com/googlegenomics/bigquery-examples/issues/12) dig more in to the reason for this difference and/or import the Var data

```r
print(expect_that(unique(cgi_variants$num_variant_alleles < gvcf_variants$num_variant_alleles), 
    is_true()))
```

```
## As expected: unique(cgi_variants$num_variant_alleles < gvcf_variants$num_variant_alleles) is true
```

```r
print(expect_equal(cgi_variants$num_variant_alleles, gvcf_variants$num_variant_alleles, 
    tolerance = 0.15))
```

```
## As expected: cgi_variants$num_variant_alleles equals gvcf_variants$num_variant_alleles
```


And of course we should have no more than 172 samples per variant record:


```
# Confirm that we are correctly expanding reference-matching blocks into our variants.
SELECT
  MAX(num_sample_ids) as max_samples_per_record,
FROM (
  SELECT
    COUNT(call.callset_name) WITHIN RECORD AS num_sample_ids,
  FROM
    [google.com:biggene:test.pgp_gvcf_variants_expanded2]
    )
```

<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:08:11 2014 -->
<TABLE border=1>
<TR> <TH> max_samples_per_record </TH>  </TR>
  <TR> <TD align="right"> 172 </TD> </TR>
   </TABLE>


Spot Check a Particular Variant
-------------------------------

```
# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story, specifically joining two 
# tables to compare the different encodings.
SELECT
  cgi.sample_id,
  chromosome,
  locusBegin,
  locusEnd,
  reference,
  allele1Seq,
  allele2Seq,
  contig_name,
  start_pos,
  end_pos,
  END,
  ref,
  alt,
  gvcf.sample_id,
  genotype
FROM
  [google.com:biggene:pgp.cgi_variants] AS cgi
  left OUTER JOIN
  (
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    ref,
    alt,
    sample_id,
    genotype
  FROM
    FLATTEN(
    SELECT
      contig_name,
      start_pos,
      end_pos,
      END,
      reference_bases AS ref,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      call.callset_name AS sample_id,
      GROUP_CONCAT(STRING(call.genotype),
        '/') WITHIN call AS genotype,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants]
    WHERE
      contig_name = '13'
      AND start_pos <= 33628138
      AND (end_pos >= 33628139
        OR END >= 33628139)
      ,
      call)) AS gvcf
ON
  cgi.sample_id = gvcf.sample_id
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138
  # Skip the genomes we were unable to convert to VCF/gVCF
OMIT RECORD IF 
  cgi.sample_id = 'huEDF7DA' OR cgi.sample_id = 'hu34D5B9'
ORDER BY
  cgi.sample_id
```

Number of rows returned by this query: 172.  We have one row for every indivudual in the CGI dataset.

Examing the NULL rows, we see that no-call records account for the difference, as we expect:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:08:15 2014 -->
<TABLE border=1>
<TR> <TH> cgi_sample_id </TH> <TH> chromosome </TH> <TH> locusBegin </TH> <TH> locusEnd </TH> <TH> reference </TH> <TH> allele1Seq </TH> <TH> allele2Seq </TH> <TH> contig_name </TH> <TH> start_pos </TH> <TH> end_pos </TH> <TH> END </TH> <TH> ref </TH> <TH> alt </TH> <TH> gvcf_sample_id </TH> <TH> genotype </TH>  </TR>
  <TR> <TD> hu67EBB3 </TD> <TD> chr13 </TD> <TD align="right"> 33628132 </TD> <TD align="right"> 33628144 </TD> <TD> = </TD> <TD> ? </TD> <TD> ? </TD> <TD>  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> </TR>
  <TR> <TD> huF1DC30 </TD> <TD> chr13 </TD> <TD align="right"> 33628132 </TD> <TD align="right"> 33628140 </TD> <TD> = </TD> <TD> ? </TD> <TD> ? </TD> <TD>  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> </TR>
   </TABLE>



```
# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story, specifically joining two 
# tables to compare the different encodings.
SELECT
  cgi.sample_id,
  chromosome,
  locusBegin,
  locusEnd,
  reference,
  allele1Seq,
  allele2Seq,
  contig_name,
  start_pos,
  end_pos,
  END,
  ref,
  alt,
  gvcf.sample_id,
  genotype
FROM
  [google.com:biggene:pgp.cgi_variants] AS cgi
  left OUTER JOIN
  (
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    ref,
    alt,
    sample_id,
    genotype
  FROM
    FLATTEN(
    SELECT
      contig_name,
      start_pos,
      end_pos,
      END,
      reference_bases AS ref,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      call.callset_name AS sample_id,
      GROUP_CONCAT(STRING(call.genotype),
        '/') WITHIN call AS genotype,
    FROM
      [google.com:biggene:test.pgp_gvcf_variants_expanded2]
    WHERE
      contig_name = '13'
      AND start_pos == 33628138
      ,
      call)) AS gvcf
ON
  cgi.sample_id = gvcf.sample_id
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138
# Skip the genomes we were unable to convert to VCF/gVCF
OMIT RECORD IF 
  cgi.sample_id = 'huEDF7DA' OR cgi.sample_id = 'hu34D5B9'
ORDER BY
  cgi.sample_id
```

Number of rows returned by this query: 172.  We have one row for every indivudual in the CGI dataset.

Examing the NULL rows, we see that no-call records account for the difference, as we expect:
<!-- html table generated in R 3.0.2 by xtable 1.7-3 package -->
<!-- Tue Aug  5 20:08:21 2014 -->
<TABLE border=1>
<TR> <TH> cgi_sample_id </TH> <TH> chromosome </TH> <TH> locusBegin </TH> <TH> locusEnd </TH> <TH> reference </TH> <TH> allele1Seq </TH> <TH> allele2Seq </TH> <TH> contig_name </TH> <TH> start_pos </TH> <TH> end_pos </TH> <TH> END </TH> <TH> ref </TH> <TH> alt </TH> <TH> gvcf_sample_id </TH> <TH> genotype </TH>  </TR>
  <TR> <TD> hu67EBB3 </TD> <TD> chr13 </TD> <TD align="right"> 33628132 </TD> <TD align="right"> 33628144 </TD> <TD> = </TD> <TD> ? </TD> <TD> ? </TD> <TD>  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> </TR>
  <TR> <TD> huF1DC30 </TD> <TD> chr13 </TD> <TD align="right"> 33628132 </TD> <TD align="right"> 33628140 </TD> <TD> = </TD> <TD> ? </TD> <TD> ? </TD> <TD>  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD align="right">  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> <TD>  </TD> </TR>
   </TABLE>


And we get the same result from both the gvcf tables:

```r
# Leave out the columns expected to differ
gvcf_result_expanded <- select(result, -start_pos, -end_pos, -END, -ref, -alt)
print(expect_equal(gvcf_result, gvcf_result_expanded))
```

```
## As expected: gvcf_result equals gvcf_result_expanded
```


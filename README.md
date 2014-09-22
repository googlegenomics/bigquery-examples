bigquery-examples
=================

The projects in this repository demonstrate working with genomic data via [Google BigQuery](https://developers.google.com/bigquery/).  All examples are built upon public datasets.

You can execute these examples by:
 1. Copying and pasting the queries into 
   * the BigQuery [Browser Tool](https://bigquery.cloud.google.com)
   * the [bq Command-Line Tool](https://developers.google.com/bigquery/bq-command-line-tool)
   * one of the many [third-party tools](https://developers.google.com/bigquery/third-party-tools) that have integrated BigQuery
 1. Running the chunks of R code within the RMarkdown files in [R](http://www.r-project.org/) or [RStudio](http://www.rstudio.com/)
 1. Running the chunks of Python code within the [iPython Notebooks](http://ipython.org/notebook.html) in [iPython](http://ipython.org/)
 
With minor modification, you can run the same analyses on your own genomic data within BigQuery.

Getting Started
-----------------
See [getting-started-bigquery](https://github.com/googlegenomics/getting-started-bigquery).

Loading your own Variant Data into BigQuery
-------------------------------------------

The Google Genomics API spec includes a not-yet-implemented [import method that loads VCF files](https://developers.google.com/genomics/v1beta/reference/variants/import) directly from Cloud Storage. Until an implementation of the method is available, you will need to transform your VCF data into JSON with a schema similar to what you see in these examples, and then load the JSON into BigQuery.  See [Preparing Data for BigQuery](https://developers.google.com/bigquery/preparing-data-for-bigquery) and also [BigQuery in Practice : Loading Data Sets That are Terabytes and Beyond](https://cloud.google.com/developers/articles/bigquery-in-practice) for more detail.

The mailing list
----------------

The [Google Genomics Discuss mailing list](https://groups.google.com/forum/#!forum/google-genomics-discuss) is a good
way to sync up with other people who use googlegenomics including the core developers. You can subscribe
by sending an email to ``google-genomics-discuss+subscribe@googlegroups.com`` or just post using
the [web forum page](https://groups.google.com/forum/#!forum/google-genomics-discuss).

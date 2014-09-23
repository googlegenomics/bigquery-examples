bigquery-examples
=================

The projects in this repository demonstrate working with genomic data via [Google BigQuery](https://developers.google.com/bigquery/).  All examples are built upon public datasets.

You can execute these examples by copying and pasting the queries into the BigQuery [Browser Tool](https://bigquery.cloud.google.com) or running the data stories from [R](http://www.r-project.org/).  All data stories have been written in [RMarkdown](http://rmarkdown.rstudio.com/).

Getting Started
-----------------
See [getting-started-bigquery](https://github.com/googlegenomics/getting-started-bigquery).

Loading your own Variant Data into BigQuery
-------------------------------------------

The Google Genomics API spec includes a [import method that loads VCF and CGI masterVar files](https://developers.google.com/genomics/v1beta/reference/variants/import) directly from Google Cloud Storage. 

For other types of data, such as variant annotations, see [Preparing Data for BigQuery](https://developers.google.com/bigquery/preparing-data-for-bigquery) and also [BigQuery in Practice : Loading Data Sets That are Terabytes and Beyond](https://cloud.google.com/developers/articles/bigquery-in-practice) for more detail.

The mailing list
----------------

The [Google Genomics Discuss mailing list](https://groups.google.com/forum/#!forum/google-genomics-discuss) is a good
way to sync up with other people who use googlegenomics including the core developers. You can subscribe
by sending an email to ``google-genomics-discuss+subscribe@googlegroups.com`` or just post using
the [web forum page](https://groups.google.com/forum/#!forum/google-genomics-discuss).

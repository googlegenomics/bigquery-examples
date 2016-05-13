Provenance
========================================================

Source Variant Data
------------------------------

### variants table

See [Google Genomics Public Data](http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/1000_genomes.html) for provenance details for this data.

Source Sample Information
--------------------------------
[Ethnicity, gender, and family relationship](http://www.1000genomes.org/faq/can-i-get-phenotype-gender-and-family-relationship-information-samples) information is available for the 1,000 Genomes dataset.  Super population groupings are described in the [FAQ](http://www.1000genomes.org/category/frequently-asked-questions/population).

Note: information for sample NA12236 is present in the pedigree table but not sample_info table.  Also sample NA12236 is not a member of the samples within table variants1kg.

### sample_info table

Description: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/README.populations
* [BigQuery table](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.sample_info?pli=1)

Source: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_sample_info.txt 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.populations.tsv
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.superpopulations.tsv

Status: 
* complete, see script [sample-info-prep.R](./sample-info-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

To load the script output via the [bq command line tool](https://cloud.google.com/bigquery/bq-command-line-tool#creatingtablefromfile), run:
```
bq load --project_id <YOUR-PROJECT_ID> --source_format=CSV \
--skip_leading_rows=1 <YOUR_DATASET.YOUR_TABLE> \
gs://genomics-public-data/1000-genomes/other/sample_info/sample_info.csv \
gs://genomics-public-data/1000-genomes/other/sample_info/sample_info.schema
```

### pedigree table

Description: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info
* [BigQuery table](https://bigquery.cloud.google.com/table/genomics-public-data:1000_genomes.pedigree?pli=1)

Source:  
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped

Status: 
* complete, no cleaning or transformation needed

To load the source file via the [bq command line tool](https://cloud.google.com/bigquery/bq-command-line-tool#creatingtablefromfile), download it to your local system and run:
```
bq load --project_id <YOUR-PROJECT_ID> --source_format=CSV \
--field_delimiter=tab --skip_leading_rows=1 <YOUR_DATASET.YOUR_TABLE> \
./20130606_g1k.ped \
Family_ID:STRING,Individual_ID:STRING,Paternal_ID:STRING,Maternal_ID:STRING,Gender:INTEGER,Phenotype:INTEGER,Population:STRING,Relationship:STRING,Siblings:STRING,Second_Order:STRING,Third_Order:STRING,Other_Comments:STRING
```

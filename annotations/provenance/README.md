Provenance
========================================================

Source Annotation Data
----------------------------------

### clinvar
ClinVar is designed to provide a freely accessible, public archive of reports of the relationships among human variations and phenotypes, with supporting evidence. 

Description: 
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/README.txt
* [BigQuery table](https://bigquery.cloud.google.com/table/google.com:biggene:annotations.clinvar?pli=1)

Source:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz
* Date Modified: 2/13/14 8:10:00 PM
* MD5: (variant_summary.txt.gz) = edc9b3fec43f0cf1d7628dd5d39f7142

Status:
* complete, see script [clinvar-prep.R](./clinvar-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

### clinvar_disease_names

Description:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/README.txt
* [BigQuery table](https://bigquery.cloud.google.com/table/google.com:biggene:annotations.clinvar_disease_names?pli=1)


Source:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/disease_names
* Date Modified: 3/10/14 
* MD5: (disease_names.txt) = 01d77ae29b2de60b46b37b46041bc9a8

Status: 
* complete, see script [clinvar-disease-names-prep.R](./clinvar-disease-name-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

### known_genes

Description:
* http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/
* [BigQuery table](https://bigquery.cloud.google.com/table/google.com:biggene:annotations.known_genes?pli=1)


Source:
* http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/knownGene.txt.gz
* Last Modified: 30-Jun-2013
* MD5 (knownGene.txt.gz) = 3e325d8080c66bc3c0db58d135d30d6d

Status: 
* complete, no cleaning or transformation needed, see script [known-gene-prep.R](./known-gene-prep.R) for merely generating the BigQuery schema

### known_genes_aliases

Description:
* http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/
* [BigQuery table](https://bigquery.cloud.google.com/table/google.com:biggene:annotations.known_genes_aliases?pli=1)

Source:
* http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/kgAlias.txt.gz
* Last Modified: 30-Jun-2013
* MD5 (kgAlias.txt.gz) = 009a037adabe85c4306618038111e363

Status: 
* complete, no cleaning or transformation needed 

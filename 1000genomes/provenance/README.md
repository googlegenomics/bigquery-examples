Provenance
========================================================

Source Variant Data
------------------------------

### variants1kG table

Description:
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20110521/README.phase1_integrated_release_version3_20120430

Source: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20110521

Files: 
* ALL.chr1.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr2.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr3.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr4.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr5.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr6.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr7.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr8.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr9.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr10.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr11.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr12.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr13.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr14.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr15.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr16.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr17.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr18.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr19.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr20.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr21.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chr22.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz
* ALL.chrX.phase1_release_v3.20101123.snps_indels_svs.genotypes.vcf.gz

Status: 
* Complete

Source Phenotypic Data
--------------------------------
Ethnicity, gender, and family relationship information is available for the 1,000 Genomes dataset.  Super population groupings are described in the FAQ.

Note: information for sample NA12236 is present in the pedigree table but not sample_info table.  Also sample NA12236 is not a member of the samples within table variants1kg.

### sample_info table

Description: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/README.populations 

Source: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_sample_info.txt 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.populations.tsv
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.superpopulations.tsv

Status: 
* complete, see script [pheno-pop-prep.R](./pheno-pop-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

### pedigree table

Description: 
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info

Source:  
* http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/20130606_g1k.ped

Status: 
* complete, no cleaning or transformation needed 

Source Annotation Data
----------------------------------

### clinvar
ClinVar is designed to provide a freely accessible, public archive of reports of the relationships among human variations and phenotypes, with supporting evidence. 

Description: 
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/README.txt

Source:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/variant_summary.txt.gz
* Date Modified: 2/13/14 8:10:00 PM
* MD5: (variant_summary.txt.gz) = edc9b3fec43f0cf1d7628dd5d39f7142

Status:
* complete, see script [clinvar-prep.R](./clinvar-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

### clinvar_disease_names

Description:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/README.txt

Source:
* http://ftp.ncbi.nlm.nih.gov/pub/clinvar/disease_names
* Date Modified: 3/10/14 
* MD5: (disease_names.txt) = 01d77ae29b2de60b46b37b46041bc9a8

Status: 
* complete, see script [clinvar-disease-name-prep.R](./clinvar-disease-name-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery

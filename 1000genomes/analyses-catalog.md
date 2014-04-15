
<!-- Don't edit this by hand, it is auto-generated documentation -->
# Variant Analyses Catalog
## Variant Data Only
* [Retrieve variants within a region](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/variant-level-data-for-brca1.sql)
 * *Category*: lookup
 * examine individual variants

* [Retrieve variants and sample genotypes within a region](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/sample-level-data-for-brca1.sql)
 * *Category*: lookup
 * examine individual variants and sample genotypes

* [Variant counts by variant type and chromosome](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/variant-counts-by-type-and-chromosome.sql)
 * *Category*: summary statistics

* [Sample variant counts by variant type and chromosome](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/sample-variant-counts-by-type-and-chromosome.sql)
 * *Category*: summary statistics

* [Ratio of variants by type and chromosome](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/ratio-of-variants-by-type.sql)
 * *Category*: summary statistics

* [Count of variants private to a particular sample](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/private-variant-counts.sql)
 * *Category*: summary statistics
 * useful in seeing at an aggregate level which samples have more variation from the reference than others; interesting only in datasets with many samples

* [Counts of variants shared by a particular number of samples](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/shared-variant-counts.sql)
 * *Category*: summary statistics

* [Counts of SNPs by ref/alt pair](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/snp-variant-counts.sql)
 * *Category*: summary statistics

* [Counts of INDELS by length](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/indel-length-counts.sql)
 * *Category*: summary statistics

* [Counts of variants grouped by genomic position windows](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/variant-hotspots.sql)
 * *Category*: summary statistics
 * useful as input to data visualization such as a heatmap to "eyeball" which areas of the genome have a higher rate of mutation than others

* [Counts of sample variants grouped by genomic position windows](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/sample-variant-hotspots.sql)
 * *Category*: summary statistics
 * useful as input to data visualization such as a heatmap to "eyeball" which areas of the genome have a higher rate of mutation than others

* [Ti/Tv ratio](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/ti-tv-ratio.sql)
 * *Category*: quality control
 * The transition transversion ratio in human is observed to be around 2.1 and this can be used as a confirmation for the filtering in a snp discovery project.

* [Het/Hom ratio](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/heterozygous-homozygous-ratio.sql)
 * *Category*: quality control

* [Gender-specific Het/Hom Ratio](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/gender-het-hom-ratio.sql)
 * *Category*: quality control
 * confirm genotypes match specified gender

* [Allelic Frequency](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/allelic-frequency.sql)
 * *Category*: summary statistics

## Variants and Phenotypes
* [Allelic Frequency by Ethnicity](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/allelic-frequency-by-ethnicity.sql)
 * *Category*: summary statistics

* [Allelic Frequency by Gender](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/allelic-frequency-by-gender.sql)
 * *Category*: summary statistics

* [Minimum Allelic Frequency by Ethnicity](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/minimum-allelic-frequency-by-ethnicity.sql)
 * *Category*: discovery

## Variants and Annotations
* [SNP clinical significance count](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/snp-clinical-significance.sql)
 * *Category*: summary statistics
 * for a dataset, view the aggregate clinical significance of variants

* [SNP disease significance count](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/snp-disease-significance.sql)
 * *Category*: summary statistics
 * for a dataset, view the aggregate disease significance of variants

* [Individual's clinically concerning variants](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/individual-clinically-concerning-variants.sql)
 * *Category*: interpretation

## Variants, Phenotypes, and Annotations
* [Familial shared clinically-concerning variants](https://github.com/GoogleCloudPlatform/genomics-bigquery/blob/master/1000genomes/sql/familial-shared-clinically-concerning-variants.sql)
 * *Category*: interpretation


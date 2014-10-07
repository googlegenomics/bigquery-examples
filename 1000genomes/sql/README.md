<!-- Don't edit this by hand, it is auto-generated documentation -->
# Variant Analyses Catalog
## Variant Data Only

Analysis | Category | Use Case
---------|----------|---------
[Retrieve variants within a region](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/variant-level-data-for-brca1.sql) | lookup | examine individual variants
[Retrieve variants and sample genotypes within a region](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/sample-level-data-for-brca1.sql) | lookup | examine individual variants and sample genotypes
[Variant counts by variant type and chromosome](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/variant-counts-by-type-and-chromosome.sql) | summary statistics | 
[Sample variant counts by variant type and chromosome](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/sample-variant-counts-by-type-and-chromosome.sql) | summary statistics | 
[Ratio of variants by type and chromosome](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/ratio-of-variants-by-type.sql) | summary statistics | 
[Count of variants private to a particular sample](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/private-variant-counts.sql) | summary statistics | useful in seeing at an aggregate level which samples have more variation from the reference than others; interesting only in datasets with many samples
[Counts of variants shared by a particular number of samples](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/shared-variant-counts.sql) | summary statistics | 
[Counts of SNPs by ref/alt pair](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/snp-variant-counts.sql) | summary statistics | 
[Counts of INDELS by length](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/indel-length-counts.sql) | summary statistics | 
[Counts of variants grouped by genomic position windows](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/variant-hotspots.sql) | summary statistics | useful as input to data visualization such as a heatmap to "eyeball" which areas of the genome have a higher rate of mutation than others
[Counts of sample variants grouped by genomic position windows](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/sample-variant-hotspots.sql) | summary statistics | useful as input to data visualization such as a heatmap to "eyeball" which areas of the genome have a higher rate of mutation than others
[Ti/Tv ratio](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/ti-tv-ratio.sql) | quality control | The transition transversion ratio in human is observed to be around 2.1 and this can be used as a confirmation for the filtering in a snp discovery project.
[Het/Hom ratio](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/heterozygous-homozygous-ratio.sql) | quality control | 
[Gender-specific Het/Hom Ratio](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/gender-het-hom-ratio.sql) | quality control | confirm genotypes match specified gender
[Allelic Frequency](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/allelic-frequency.sql) | summary statistics | 
[Hardy-Weinberg Equilibrium](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/hardy-weinberg-equilibrium.sql) | quality control | 

## Variants and Phenotypes

Analysis | Category | Use Case
---------|----------|---------
[Allelic Frequency by Ethnicity](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/allelic-frequency-by-ethnicity.sql) | summary statistics | 
[Allelic Frequency by Gender](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/allelic-frequency-by-gender.sql) | summary statistics | 
[Minimum Allelic Frequency by Ethnicity](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/minimum-allelic-frequency-by-ethnicity.sql) | discovery | 
[Simplistic GWAS Pattern, Chi Squared test](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/gwas-pattern-chi-squared-test.sql) | discovery | 
[Simplistic GWAS Pattern, two proportion z-score test](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/gwas-pattern-two-proportion-z-test.sql) | discovery | 


## Variants and Annotations

Analysis | Category | Use Case
---------|----------|---------
[SNP clinical significance count](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/snp-clinical-significance.sql) | summary statistics | for a dataset, view the aggregate clinical significance of variants
[SNP disease significance count](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/snp-disease-significance.sql) | summary statistics | for a dataset, view the aggregate disease significance of variants
[Variant counts by gene](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/gene-variant-counts.sql) | summary statistics | 
[Variant counts for a sample by gene](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/sample-gene-variant-counts.sql) | summary statistics | 
[Variant counts for specific genes](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/specific-gene-variant-counts.sql) | summary statistics | 
[Individual's clinically concerning variants](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/individual-clinically-concerning-variants.sql) | interpretation | 
## Variants, Phenotypes, and Annotations

Analysis | Category | Use Case
---------|----------|---------
[Familial shared clinically-concerning variants](https://github.com/googlegenomics/bigquery-examples/tree/master/1000genomes/sql/familial-shared-clinically-concerning-variants.sql) | interpretation | 

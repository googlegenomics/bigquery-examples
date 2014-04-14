library(plyr)
library(testthat)

# Preprocessing performed
# (1) exported individual sheets as CSV from 20130606_sample_info.xlsx
# (2) some files had two header rows which were manually condensed into one

dataDir = './'

# Ordered by importance
# sample_info > DNA_source > HD Genotypes > Final QC results > Final Phase Sequence Data > Phase 1
files = c(
	'20130606_sample_info.csv',
	'20130606_sample_dna_source.csv',
	'20130606_sample_hd_genotypes.csv',
	'20130606_sample_final_qc_results.csv',
	'20130606_sample_final_phase_sequence_data.csv',
	'20130606_sample_phase1.csv'
	)

# Load Data
phenos = lapply(files, function(file) {
  data = read.csv(file.path(dataDir, file), na.strings=c('NA', 'N/A'))
  print(paste('file:', file, 'nrow:', nrow(data), 'ncol:', ncol(data)))
  print(paste(colnames(data)))
  expect_that(nrow(data), equals(3500))
  data
})

# Check our JOIN criteria
sample_ids = phenos[[1]]$Sample
population = phenos[[1]]$Population
expect_that(length(sample_ids), equals(3500))
expect_that(length(unique(sample_ids)), equals(3500))
lapply(phenos, function(pheno) {
	expect_that(pheno$Sample, equals(sample_ids))
	expect_that(pheno$Population, equals(population))
})

# Join it all together
joined_pheno = Reduce(function(x, y) { join(x, y, type='inner', match='first') }, phenos)
expect_that(nrow(joined_pheno), equals(3500))

# Clean column names
colnames(joined_pheno) = tolower(colnames(joined_pheno))
colnames(joined_pheno) = gsub('\\.+', '_', colnames(joined_pheno))

# Generate BQ Schema
cols = colnames(joined_pheno)
empty_ints = c(NA)
bool_ints = c(0, 1, NA)
to_drop = c()
schema = c()
for (i in 1:length(cols)) {
    type = 'STRING'
    if('logical' == class(joined_pheno[,i])) {
        type = 'BOOLEAN'
        if(setequal(empty_ints, union(empty_ints, joined_pheno[,i]))) {
            to_drop = append(to_drop, cols[i])
            print(paste('DROPPING', cols[i]))
            next
        }
    } else if ('numeric' == class(joined_pheno[,i])) {
        type = 'FLOAT'
    } else if ('integer' == class(joined_pheno[,i])) {
        if(setequal(bool_ints, union(bool_ints, joined_pheno[,i]))) {
            type = 'BOOLEAN'
        } else {
            type = 'INTEGER'
        }
    }
    schema = append(schema, paste(cols[i],':', type, sep='', collapse=','))
}
print(paste(schema, collapse=','))

# Drop empty columns
cleaned_pheno = joined_pheno[,!(names(joined_pheno) %in% to_drop)]

# Spot check our result
expect_that(as.character(subset(cleaned_pheno, sample == 'HG00114', select=exome_total_sequence)[1,1]), equals('10,374,134,700'))
expect_that(subset(cleaned_pheno, sample == 'HG00114', select=low_coverageebv_coverage)[1,1], equals(10.78))

# Write out file to load into BigQuery
write.csv(cleaned_pheno, file.path(dataDir, 'phenotypes1kg.csv'), row.names=FALSE, na="")

# TODO
# (1) use tab-delimited version of source file
# (2) add descriptions from http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info

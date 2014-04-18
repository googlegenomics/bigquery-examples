library(testthat)

# Preprocessing performed: none
dataDir = './'

# Load Data
data = read.delim(file.path(dataDir,'knownGene.txt.gz'), header=FALSE)
expect_that(nrow(data), equals(82960))
expect_that(ncol(data), equals(12))

# Generate BQ Schema
description = list() # TODO(deflaux@): descriptions
cols = c('name', 'chrom', 'strand', 'txStart', 'txEnd', 'cdsStart',
    'cdsEnd', 'exonCount', 'exonStarts', 'exonEnds', 'proteinID', 'alignID')
schema = c()
for (i in 1:length(cols)) {
    type = 'STRING'
    if('logical' == class(data[,i])) {
        type = 'BOOLEAN'
    } else if ('numeric' == class(data[,i])) {
        type = 'FLOAT'
    } else if ('integer' == class(data[,i])) {
        type = 'INTEGER'
    }
    schema = append(schema, paste("{'name':'", cols[i],"', 'type':'", type, "', 'description':'", description[[cols[i]]], "'}", sep="", collapse=","))
}
print(paste(schema, collapse=','))





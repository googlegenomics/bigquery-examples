# Copyright 2014 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script to auto-generate BigQuery schema and clean the data for BigQuery ingestion
library(testthat)

# Preprocessing performed: none
dataDir <- './'

# Load Data
data <- read.delim(file.path(dataDir, 'disease_names.txt'))
expect_that(nrow(data), equals(16020))
expect_that(ncol(data), equals(6))

# Clean column names
colnames(data) <- gsub('\\.+', '_', colnames(data))
colnames(data) <- gsub('^X_', '', colnames(data))
colnames(data) <- gsub('_$', '', colnames(data))

# Generate BQ Schema
description <- list(
    DiseaseName='The name preferred by GTR and ClinVar',
    SourceName='Sources that also use this preferred name',
    ConceptID='The identifier assigned to a disorder associated with this gene. If the value starts with a C and is followed by digits, the ConceptID is a value from UMLS; if a value begins with CN, it was created by NCBI-based processing.',
    SourceID='Identifier used by the source reported in column 2',
    DiseaseMIM='MIM number for the condition.',
    LastUpdated='Last time this record was modified by NCBI staff')
cols <- colnames(data)
schema <- c()
for (i in 1:length(cols)) {
    type <- 'STRING'
    if ('logical' == class(data[, i])) {
        type <- 'BOOLEAN'
    } else if ('numeric' == class(data[, i])) {
        type <- 'FLOAT'
    } else if ('integer' == class(data[, i])) {
        type <- 'INTEGER'
    }
    schema <- append(schema, paste("{'name':'", cols[i], "', 'type':'",
      type, "', 'description':'", description[[cols[i]]], "'}",
      sep="", collapse=","))
}
print(paste(schema, collapse=','))

# Write out file to load into BigQuery
write.table(data, file.path(dataDir, 'clinvar-disease-names.csv'),
            row.names=FALSE, sep='\t', na='')

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

# Script to auto-generate BigQuery schema
library(testthat)

# Preprocessing performed: none
dataDir <- './'

# Load Data
data <- read.delim(file.path(dataDir, 'knownGene.txt.gz'), header=FALSE)
expect_that(nrow(data), equals(82960))
expect_that(ncol(data), equals(12))

# Generate BQ Schema
description <- list() # TODO(deflaux@): descriptions
cols <- c('name', 'chrom', 'strand', 'txStart', 'txEnd', 'cdsStart',
          'cdsEnd', 'exonCount', 'exonStarts', 'exonEnds', 'proteinID',
          'alignID')
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

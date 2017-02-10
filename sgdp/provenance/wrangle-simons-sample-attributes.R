# Copyright 2017 Google Inc. All rights reserved.
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

# Wrangle sample attributes for Simons Genome Diversity Project Data.  See also:
# https://www.simonsfoundation.org/life-sciences/simons-genome-diversity-project-dataset/
# http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/simons_foundation.html

library(testthat)
library(XML)
library(reshape2)
library(dplyr)
library(stringr)

study <- read.delim("https://www.ebi.ac.uk/ena/data/warehouse/filereport?accession=PRJEB9586&result=read_run&fields=study_accession,sample_accession,secondary_sample_accession,experiment_accession,run_accession,tax_id,scientific_name,instrument_model,library_layout,fastq_ftp,fastq_galaxy,submitted_ftp,submitted_galaxy,sra_ftp,sra_galaxy,cram_index_ftp,cram_index_galaxy&download=txt",
                    header=T)

accessions <- unique(study$sample_accession)
expect_that(length(accessions), equals(279))

simons_attributes <- function(x) {
  raw <- xmlParse(paste0("http://www.ebi.ac.uk/ena/data/view/", x, "%26display%3Dxml"))
  parsed <- xpathApply(raw, "//ROOT/SAMPLE/SAMPLE_ATTRIBUTES", xmlToDataFrame)
  long <- mutate(parsed[[1]],
                 era_id=x)
}

all <- do.call(rbind, lapply(accessions, simons_attributes))
expect_that(ncol(all), equals(3))

# Fix attribute name "Sex" versus "sex" by lower casing all attribute names.
all$TAG = tolower(all$TAG)

# Fix attribute name "geographic location (country and/or sea)" versus "country".
all$TAG =  gsub("geographic location (country and/or sea)",
                "country",
                all$TAG,
                fixed=TRUE)

# Reshape long attribute list into wide format.
wide <- reshape(all, idvar = "era_id", timevar="TAG", direction = "wide")
expect_that(nrow(wide), equals(279))

# Tidy up the column names.
colnames(wide) <- gsub("VALUE.", "", colnames(wide))
colnames(wide) <- gsub("-", "_", colnames(wide))
colnames(wide) <- gsub(" ", "_", colnames(wide))

# In two cases the library name instead of the Illumina ID is what ended up in the VCF file.
# SS6004478 == LP6005442-DNA_A09 per http://www.ebi.ac.uk/ena/data/view/SAMEA3302719
# SS6004477 == LP6005442-DNA_B09 per http://www.ebi.ac.uk/ena/data/view/SAMEA3302681

# There is one final case where the Illumina ID does not match the id in any VCF, so by
# process of elimination, remapping that one too.
# LP6005443-DNA_C01 == LP6005441-DNA_A09 per process of elimination

# Add a new column holding repaired values.
wide_remapped = mutate(wide,
                       id_from_vcf=illumina_id)
wide_remapped$id_from_vcf = gsub("LP6005442-DNA_A09",
                                 "SS6004478",
                                 wide_remapped$id_from_vcf,
                                 fixed=TRUE)
wide_remapped$id_from_vcf = gsub("LP6005442-DNA_B09",
                                 "SS6004477",
                                 wide_remapped$id_from_vcf,
                                 fixed=TRUE)

write.csv(wide_remapped, "simons-sample-attributes.csv", row.names=FALSE, na="")

# Then load the resulting file to BigQuery via:
# bq load --autodetect THE_DATASET.THE_TABLE simons-sample-attributes.csv

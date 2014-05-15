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

# Script to auto-generate BigQuery schema and clean the data for BigQuery import.
library(reshape)
library(plyr)
library(dplyr)
library(testthat)

dataDir <- './'

#----------------------------------------------------------------------------
# Load Demographic Data
demo <- read.csv(file.path(dataDir, 'PGPParticipantSurvey-20140506220023.csv'),
                 stringsAsFactors=FALSE,
                 na.strings=c('NA', 'N/A', 'No response', 'null', ''))
expect_equal(nrow(demo), 2627)
expect_equal(ncol(demo), 52)
# Substitute whitespace and punctuation for underscores
colnames(demo) <- gsub('\\W+', '_', colnames(demo))
# Trim trailing underscores
colnames(demo) <- gsub('_+$', '', colnames(demo))
# PGP participants have filled out the surveys multiple times
expect_less_than(length(unique(demo$Participant)), nrow(demo))
# Drop a few columns
drops <- c('Do_not_touch',
           'Do_you_have_a_severe_genetic_disease_or_rare_genetic_trait_If_so_you_can_add_a_description_for_your_public_profile',
           'Disease_trait_Documentation_description')
demo <- demo[,!(names(demo) %in% drops)]

# Convert Timestamp column to dates
demo$Timestamp <- strptime(as.character(demo$Timestamp), '%m/%d/%Y %H:%M:%S')
demo$Timestamp <- as.POSIXct(demo$Timestamp)
# Filter, keeping only most recent survey per participant
recentDemo <- demo %.%
  group_by(Participant) %.%
  arrange(desc(Timestamp)) %.%
  filter(row_number(Participant) == 1)
expect_equal(length(unique(demo$Participant)), nrow(recentDemo))
# Spot check the data
expect_equal(recentDemo[recentDemo$Participant == 'huD554DB',]$Timestamp,
             as.POSIXct('2014-02-07 12:20:52 PST'))

#----------------------------------------------------------------------------
# Load Phenotypic Trait Data
files <- c(
  'PGPTrait&DiseaseSurvey2012-Blood-20140506220045.csv',
  'PGPTrait&DiseaseSurvey2012-Cancers-20140506220037.csv',
  'PGPTrait&DiseaseSurvey2012-CirculatorySystem-20140506220056.csv',
  'PGPTrait&DiseaseSurvey2012-CongenitalTraitsAndAnomalies-20140506220117.csv',
  'PGPTrait&DiseaseSurvey2012-DigestiveSystem-20140506220103.csv',
  'PGPTrait&DiseaseSurvey2012-Endocrine,Metabolic,Nutritional,AndImmunity-20140506220041.csv',
  'PGPTrait&DiseaseSurvey2012-GenitourinarySystems-20140506220107.csv',
  'PGPTrait&DiseaseSurvey2012-MusculoskeletalSystemAndConnectiveTissue-20140506220114.csv',
  'PGPTrait&DiseaseSurvey2012-NervousSystem-20140506220048.csv',
  'PGPTrait&DiseaseSurvey2012-RespiratorySystem-20140506220059.csv',
  'PGPTrait&DiseaseSurvey2012-SkinAndSubcutaneousTissue-20140506220111.csv',
  'PGPTrait&DiseaseSurvey2012-VisionAndHearing-20140506220052.csv'
  )

traits <- lapply(files, function(file) {
  data <- read.csv(file.path(dataDir, file),
                   stringsAsFactors=FALSE,
                   na.strings=c('NA', 'N/A', 'No response', 'null', ''))
  print(paste('file:', file, 'nrow:', nrow(data), 'ncol:', ncol(data)))
  expect_equal(ncol(data), 5)
  # This column name differs between the surveys but its the same data.  Update
  # the column name so that we can join all this data together.
  if('Have.you.ever.been.diagnosed.with.one.of.the.following.conditions.' == colnames(data)[4]) {
    colnames(data)[4] <- 'Have.you.ever.been.diagnosed.with.any.of.the.following.conditions.'
  }
  expect_equal(colnames(data), c('Participant',
                                 'Timestamp',
                                 'Do.not.touch.',
                                 'Have.you.ever.been.diagnosed.with.any.of.the.following.conditions.',
                                 'Other.condition.not.listed.here.'))
  # PGP participants have filled out the surveys multiple times
  expect_less_than(length(unique(data$Participant)), nrow(data))
  data
})
trait <- do.call(rbind, traits)
expect_equal(ncol(trait), 5)
expect_equal(nrow(trait), sum(unlist(lapply(traits, nrow))))

# Convert Timestamp column to dates
trait$Timestamp <- strptime(as.character(trait$Timestamp), '%m/%d/%Y %H:%M:%S')
trait$Timestamp <- as.POSIXct(trait$Timestamp)
trait <- arrange(trait, desc(Timestamp))

# Reshape the trait data such that conditions are individual columns.
longTrait <- ddply(trait, .(Participant), function(data) {
  conditions <- unlist(strsplit(c(as.character(data$Have.you.ever.been.diagnosed.with.any.of.the.following.conditions.)), ','))
  # Trim leading and trailing whitespace and punctuation
  conditions <- gsub('^\\W+', '', conditions)
  conditions <- gsub('\\W+$', '', conditions)
  # Substitute whitespace and punctuation for underscores
  conditions <- gsub('\\W+', '_', conditions)
  data.frame(Participant = rep(unique(data$Participant), length(conditions)),
             Timestamp = rep(unique(data$Timestamp), length(conditions)),             
             conditions = conditions)
})
longTrait <- cbind(longTrait, has=rep(TRUE, nrow(longTrait)))
wideTrait <- reshape(longTrait,
                     idvar = 'Participant',
                     timevar='conditions',
                     v.names='has', 
                     direction = 'wide')
expect_equal(length(unique(wideTrait$Participant)), nrow(wideTrait))
# Substitute whitespace and punctuation for underscores
colnames(wideTrait) <- gsub('\\W$', '', colnames(wideTrait))
colnames(wideTrait) <- gsub('\\W+', '_', colnames(wideTrait))

# Spot check our data to verify that it was reshaped correctly.
expect_true(wideTrait[wideTrait$Participant=='hu005023', 'has_Dental_cavities'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu005023', 'has_Gastroesophageal_reflux_disease_GERD']))
expect_true(wideTrait[wideTrait$Participant=='hu005023', 'has_Impacted_tooth'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu005023', 'has_Skin_tags']))
expect_true(is.na(wideTrait[wideTrait$Participant=='hu005023', 'has_Hair_loss_includes_female_and_male_pattern_baldness']))
expect_true(is.na(wideTrait[wideTrait$Participant=='hu005023', 'has_Acne']))
expect_true(wideTrait[wideTrait$Participant=='hu005023', 'has_Allergic_contact_dermatitis'])

expect_true(wideTrait[wideTrait$Participant=='hu627574', 'has_Dental_cavities'])
expect_true(wideTrait[wideTrait$Participant=='hu627574', 'has_Gastroesophageal_reflux_disease_GERD'])
expect_true(wideTrait[wideTrait$Participant=='hu627574', 'has_Impacted_tooth'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu627574', 'has_Skin_tags']))
expect_true(wideTrait[wideTrait$Participant=='hu627574', 'has_Hair_loss_includes_female_and_male_pattern_baldness'])
expect_true(wideTrait[wideTrait$Participant=='hu627574', 'has_Acne'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu627574', 'has_Allergic_contact_dermatitis']))

expect_true(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Dental_cavities'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Gastroesophageal_reflux_disease_GERD']))
expect_true(is.na(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Impacted_tooth']))
expect_true(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Skin_tags'])
expect_true(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Hair_loss_includes_female_and_male_pattern_baldness'])
expect_true(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Acne'])
expect_true(is.na(wideTrait[wideTrait$Participant=='hu8E2A35', 'has_Allergic_contact_dermatitis']))

#----------------------------------------------------------------------------
# Some participants only filled out trait surveys, others only filled out the
# participant survey
expect_false(setequal(recentDemo$Participant, 
                      intersect(wideTrait$Participant, recentDemo$Participant)))
expect_false(setequal(wideTrait$Participant, 
                      intersect(wideTrait$Participant, recentDemo$Participant)))

# JOIN it all together, dropping the Timestamp columns
pheno <- join(recentDemo[,-2], wideTrait[,-2], type='full')
expect_equal(nrow(pheno), 
             length(union(wideTrait$Participant, recentDemo$Participant)))

# Generate BQ Schema
cols <- colnames(pheno)
bool_ints <- c(0, 1, NA)
schema <- c()
for (i in 1:length(cols)) {
    type <- 'STRING'
    if ('logical' == class(pheno[, i])) {
        type <- 'BOOLEAN'
    } else if ('numeric' == class(pheno[, i])) {
        type <- 'FLOAT'
    } else if ('integer' == class(pheno[, i])) {
        if (setequal(bool_ints, union(bool_ints, pheno[, i]))) {
            type <- 'BOOLEAN'
        } else {
            type <- 'INTEGER'
        }
    }
    schema <- append(schema, paste(cols[i], type,
      sep=":", collapse=","))
}
print(paste(schema, collapse=','))

# Write out file to load into BigQuery
write.table(pheno, file.path(dataDir, 'pgp-phenotypes.tsv'),
            row.names=FALSE, sep='\t', na='')

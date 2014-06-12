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

# Script to auto-generate BigQuery schema for BigQuery ingestion
library(testthat)

# Descriptions from
# http://media.completegenomics.com/documents/DataFileFormats+Standard+Pipeline+2.0.pdf
description <- list(
    sample_id='Sample ID',
    locus='Integer ID of the locus. When converting a Complete Genomics variant file, all loci will retain the original IDs. When processing filtered files where regions have been removed, the loci that correspond to the removed regions are recreated with a locus ID 0 and are considered fully no-called.',
    ploidy='Number of alleles (same as in the Complete Genomics variations file).',
    chromosome='Chromosome name (same as in the Complete Genomics variations file).',
    # 'begin' and 'end' are the column names in the source data but are
    # reserved words for BigQuery and should not be used as column names
    locusBegin='Locus start. Zero-based offset of the first base in the locus, the same as in the Complete Genomics variations file.',
    locusEnd='Locus end. Zero-based offset of the first base downstream of the locus, same as in the Complete Genomics variations file.',
    zygosity='Call completeness and zygosity information. zygosity is assigned one of the following values:
 - no-call: All alleles are partially or fully no-called.
 - hap: Haploid, fully called locus.
 - half: Diploid locus where one of the alleles is fully called and the other contains no-calls.
 - hom: Diploid, homozygous, fully called locus.
 - het-ref: Diploid, heterozygous, fully called locus where one of the alleles is identical to the reference.
 - het-alt: Diploid, heterozygous, fully called locus where both alleles differ from the reference.',
    varType='Variation type for simple, isolated variations. varType is assigned one of the following values:
 - snp, ins, del, or sub: Fully called or half-called locus that contains only a single isolated variation.
 - ref: Fully called or half-called locus that contains only reference calls and no calls and at least one allele is fully called.
 - complex: Locus that contains multiple variations or has no-calls in all alleles.  This is also the value for all loci where the reference itself is ambiguous.
 - no-ref: Locus where the reference genome is N.
 - PAR-called-in-X: Locus on the pseudo-autosomal region of the Y chromosomes in males.',
    reference='Reference sequence. Loci called as homozygous reference and loci that are fully no-called on all alleles will contain “=” instead of the literal reference sequence.',
    allele1Seq='Sequence of the first allele. May contain N and ? characters that represent onebase no-calls and unknown length no-calls, respectively, with the same semantics as used for “alleleSeq” in the Complete Genomics variant file.  The field is empty when the called variant is a deletion of all bases in the locus.  For a given locus, if the allele in the variation file spans multiple lines, then the sequences for each call corresponding that the allele are concatenated.',
    allele2Seq='Sequence of the second allele. The value of allele2Seq follows the same rules as allele1Seq. This field is always blank for haploid loci (whenever the ploidy field contains 1).  The values of allele1Seq and allele2Seq are assigned such that a variation allele always precedes a pure reference allele, and a fully called allele always precedes any allele that contains no-calls. As a result, the allele order may differ from the order in the corresponding source variations file.',
    allele1VarScoreVAF='Positive integer representing confidence in the call for the first allele. It is derived from the probability estimates under maximum likelihood variable allele fraction.  This field is empty for reference calls or no-calls.',
    allele2VarScoreVAF='Positive integer representing confidence in the call for the second allele. It is derived from the probability estimates under maximum likelihood variable allele fraction.  This field is empty for reference calls or no-calls.',
    allele1VarScoreEAF='Positive or negative integer representing confidence in the call for the first allele. It is derived from the probability estimates under equal allele fraction model. This field is empty for reference calls or no-calls. Variants are called based on varScoreVAF. Thus, it is possible that a called variant has a negative varScoreEAF value, indicating that the top hypothesis is not the most likely hypothesis under the EAF model, but is the most likely hypothesis under the VAF model.',
    allele2VarScoreEAF='Positive or negative integer representing confidence in the call for the second allele. It is derived from the probability estimates under equal allele fraction model.  This field is empty for reference calls or no-calls. Variants are called based on varScoreVAF. Thus, it is possible that a called variant has a negative varScoreEAF value, indicating that the top hypothesis is not the most likely hypothesis under the EAF model, but is the most likely hypothesis under the VAF model.',
    allele1VarQuality='Indicates confidence category for the allele 1 call. Possible values are: VQLOW or VQHIGH, based on allele1VarScoreVAF where VQHIGH is assigned for homozygous calls with score of at least 20 dB and other scored calls with score of at least 40 dB.',
    allele2VarQuality='Indicates confidence category for the allele 2 call. Possible values are: VQLOW or VQHIGH, based on allele1VarScoreVAF where VQHIGH is assigned for homozygous calls with score of at least 20 dB and other scored calls with score of at least 40 dB.',
    allele1HapLink='Integer ID that links the first allele to the alleles of other loci that are known to reside on the same haplotype.',
    allele2HapLink='Integer ID that links the second allele to the alleles of other loci that are known to reside on the same haplotype.',
    allele1XRef='Semicolon-separated list of all xRef annotations for allele 1.',
    allele2XRef='Semicolon-separated list of all xRef annotations for allele 2.',
    evidenceIntervalId='Integer ID of the interval in the evidence file. Multiple loci may share the same evidence interval.',
    allele1ReadCount='Number of reads that support the first allele. A read is included in the count if it overlaps the locus interval and supports the allele by at least 3 dB more than the other allele or the reference. For length-preserving variations, at least one base in the read must overlap the interval to be included in the read count. For length-changing variations, the read may be counted even if it overlaps the variation with its intra-read gap.',
    allele2ReadCount='Number of reads that support the second allele. For homozygous loci, this number is identical to allele1ReadCount.',
    referenceAlleleReadCount='Number of reads that support the reference sequence. For loci where one of the alleles is reference, this number is identical to the read count of that allele.',
    totalReadCount='Total number of reads in the evidence file that overlap the interval. Note that this count also includes reads that do not strongly support one allele over the other and consequently are not accounted for in allele1ReadCount or allele2ReadCount. For loci where one of the alleles contains a no-call, the totalReadCount also includes the reads that support that no-called allele. The totalReadCount does not include reads that do not overlap the locus, even if they do overlap the evidence interval, and, hence, are present in the evidence file.',
    allele1Gene='Semicolon-separated list of all gene annotations for the first allele of the locus.  For every gene annotation, the following fields from the gene file are concatenated together using colon as separator: geneId, mrnaAcc, symbol, component, and impact. For example:
      100130417:NR_026874.1:FLJ39609:TSS-UPSTREAM:UNKNOWNINC;148398:NM_152486.2:SAMD11:TSS-UPSTREAM:UNKNOWN-INC',
    allele2Gene='Gene annotation list for the second allele formatted in the same way as allele1Gene.',
    pfam='Pfam domain information that overlap with the locus.',
    miRBaseId='Semicolon-separated list of all ncRNA annotations for this locus.',
    repeatMasker='Semicolon-separated list of all RepeatMasker records that overlap this locus. Within each record, the following data is concatenated together using colon as the separator:
      - repeat name
      - repeat family
      - overall divergence percentage (number of bases changed, deleted, or inserted relative to the repeat consensus sequence per hundred bases)
Mitochondrion loci are not annotated.  See RepeatMasker in “References” for more information.',
    segDupOverlap='Number of distinct segmental duplications that overlap this locus.',
    relativeCoverageDiploid='Normalized coverage level, under a diploid model, for the segment that overlaps the current locus (for loci that overlap two segments, the data from the cnvSegmentsDiploidBeta file with the longer overlap are chosen). This column corresponds to the relativeCvg field in the cnvSegmentsDiploidBeta file.',
    calledPloidy='Ploidy of the segment, as called using a diploid model. Only present if the ploidy calls were made during the assembly (only when the calledPloidy column is present in the source cnvSegmentsDiploidBeta file). This column corresponds to the calledPloidy field in the cnvSegmentsDiploidBeta file.',
    relativeCoverageNondiploid=' Normalized coverage level, under a nondiploid model, for the segment that overlaps the current locus (for loci that overlap two segments, the data from the cnvSegmentsNondiploidBeta file with the longer overlap are chosen). This column corresponds to the relativeCvg field in the cnvSegmentsNondiploidBeta file.',
    calledLevel='Coverage level of the segment, as called using a non-diploid model. Only present if the ploidy coverage levels were made during the assembly (only when the calledLevel column is present in the source cnvSegmentsNondiploidBeta file). This column corresponds to the calledLevel field in the cnvSegmentsNondiploidBeta file.'
)

dataDir <- './'
# Load a subset of data from our Hadoop job
data <- read.delim(file.path(dataDir, 'part-00028'),
                   col.names=names(description))
expect_that(ncol(data), equals(36))

## Load a subset of the source CGI data
#data <- read.delim(file.path(dataDir, 'masterVarBeta-GS000015891-ASM-brief.tsv'),
#                             skip=19,
#                             header=TRUE)
#expect_that(ncol(data), equals(35))
## Clean column names
#colnames(data) <- gsub('^X\\.', '', colnames(data))
## 'begin' and 'end' are reserved words for BigQuery and should not be used
## as column names
#colnames(data) <- gsub('begin', 'locusBegin', colnames(data))
#colnames(data) <- gsub('end', 'locusEnd', colnames(data))

# Generate BQ Schema
cols <- colnames(data)
bool_ints <- c(0, 1, NA)
schema <- c()
for (i in 1:length(cols)) {
  type <- 'STRING'
  if ('logical' == class(data[, i])) {
    type <- 'BOOLEAN'
  } else if ('numeric' == class(data[, i])) {
    type <- 'FLOAT'
    # In the full dataset, field relativeCoverageDiploid contains some values that are 'N'
    if(cols[i] == 'relativeCoverageDiploid') { type <- 'STRING'}
  } else if ('integer' == class(data[, i])) {
    if (setequal(bool_ints, union(bool_ints, data[, i]))) {
      type <- 'BOOLEAN'
    } else {
      type <- 'INTEGER'
    }
  }
  schema <- append(schema, paste("{'name':'", cols[i], "', 'type':'",
                                 type, "', 'description':'", description[[cols[i]]], "'}",
                                 sep="", collapse=","))
}
print(paste(schema, collapse=','))

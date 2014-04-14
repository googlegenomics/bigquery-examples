library(plyr)
library(testthat)

data_dir = './'

# Load Data
pheno = read.delim(file.path(data_dir, '20130606_sample_info.txt'), na.strings=c('NA', 'N/A'))
expect_that(nrow(pheno), equals(3500))
expect_that(ncol(pheno), equals(61))

pop = read.delim(file.path(data_dir, '20131219.populations.tsv'), na.strings=c('NA', 'N/A'))
expect_that(nrow(pop), equals(29))
expect_that(ncol(pop), equals(9))

super_pop = read.delim(file.path(data_dir, '20131219.superpopulations.tsv'), na.strings=c('NA', 'N/A'))
expect_that(nrow(super_pop), equals(5))
expect_that(ncol(super_pop), equals(2))

# Fix colnames so that colnames to JOIN upon match
colnames(pop) = gsub('Population.Code', 'Population', colnames(pop))
colnames(super_pop) = gsub('Population.Code', 'Super.Population', colnames(super_pop))
colnames(super_pop) = gsub('Description', 'Super.Population.Description', colnames(super_pop))

# Check our JOIN criteria
expect_that(length(union(as.character(pop$Population),
                         as.character(pheno$Population))),
            equals(27))
expect_that(setdiff(as.character(pop$Population),
                    as.character(pheno$Population)),
            equals(c("")))
expect_that(setdiff(as.character(super_pop$Super.Population),
                    as.character(pop$Super.Population)),
            equals(character(0)))

# JOIN it all together
pop_data = join(pop[,colnames(pop) %in% c('Population','Population.Description','Super.Population')], super_pop)
data = join(pheno, pop_data, type='inner')
expect_that(nrow(data), equals(3500))
expect_that(ncol(data), equals(63))

# Clean column names
colnames(data) = gsub('\\.+', '_', colnames(data))
colnames(data) = gsub('E_Indel_Ration', 'E_Indel_Ratio', colnames(data))

# Descriptions from
# http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20130606_sample_info/README_20130606_sample_info
description = list(
    Sample='Sample ID',
    Family_ID='Family ID',
    Population='3 letter population cod',
    Population_Description='Description of Population',
    Gender='',
    Relationship='Relationship to other members of the family',
    Unexpected_Parent_Child='sample id for unexpected parent child relationships',
    Non_Paternity='sample ids for annotated non paternal relationships',
    Siblings='sample ids for any siblings',
    Grandparents='sample ids for any grand parents',
    Avuncular='sample ids for any avuncular relationships',
    Half_Siblings='sample ids for any half siblings',
    Unknown_Second_Order='sample ids for any unknown second order relations',
    Third_Order='sample ids for any third order cryptic relations. As mentioned above, this analysis was not as widely run as the other relatedness analyses and as such there may still be unannotated third order relations in the set',
    Other_Comments='other comments with respect to known mutations etc',
    In_Low_Coverage_Pilot='The sample is in the low coverage pilot experiment',
    LC_Pilot_Platforms='low coverage pilot sequencing platforms	',
    LC_Pilot_Centers='low coverage pilot sequencing centers',
    In_High_Coverage_Pilot='The sample is in the high coverage pilot',
    HC_Pilot_Platforms='high coverage sequencing platforms',
    HC_Pilot_Centers='high coverage sequencing centers',
    In_Exon_Targetted_Pilot='The Sample is in the exon targetted pilot experiment',
    ET_Pilot_Platforms='exon targetted sequencing platforms,',
    ET_Pilot_Centers='exon targetted sequencing centers,',
    Has_Sequence_in_Phase1='Has sequence low coverage sequence in the 20101123.sequence.index file or exome sequence in the 20110522 sequence index file',
    Phase1_LC_Platform='phase1 low coverage sequencing platforms',
    Phase1_LC_Centers='phase1 low coverage sequencing centers',
    Phase1_E_Platform='phase1 exome sequencing platforms',
    Phase1_E_Centers='phase1 exome sequencing centers',
    In_Phase1_Integrated_Variant_Set='The sample is genotyped in the phase1 integrated call set on autosomes and chrX',
    Has_Phase1_chrY_SNPS='The sample is genotyped in the chrY phase1 snp set',
    Has_phase1_chrY_Deletions='The sample is genotyepd in the chrY phase1 deletions',
    Has_phase1_chrMT_SNPs='The sample is genotyped in the phase1 chrMT snps',
    Main_project_LC_Centers='low coverage sequencing centers for final sequencing round',
    Main_project_LC_platform='low coverage sequencing platform for final sequencing round',
    Total_LC_Sequence='The total amount of low coverage sequence available',
    LC_Non_Duplicated_Aligned_Coverage='The non duplicated aligned coverage for the low coverage sequence data.  This was calculated using the ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/alignment_indices/20130502.low_coverage.alignment.index.bas.gz file, the (mapped bases - duplicated bases) was summed for each sample and divided by 2.75GB and rounded to 2dp',
    Main_Project_E_Centers='Exome sequencing centers for the final sequencing round',
    Main_Project_E_Platform='Exome sequencing platform for the final sequencing round',
    Total_Exome_Sequence='The total amount of exome sequence available',
    X_Targets_Covered_to_20x_or_greater='The percentage of targets covered to 20x or greater as calculated by the picard function CalculateHsMetrics using these targets ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/exome_pull_down_targets_phases1_and_2/20120518.consensus.annotation.bed',
    VerifyBam_E_Omni_Free='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_E_Affy_Free='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_E_Omni_Chip='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_E_Affy_Chip='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_LC_Omni_Free='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_LC_Affy_Free='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_LC_Omni_Chip='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    VerifyBam_LC_Affy_Chip='Value from UMich\'s VerifyBamID BAM QC program http://genome.sph.umich.edu/wiki/VerifyBamID.  The Free measures use a statistical model based on the haplotypes discovered by the chip. The Chip measure considers the genotypes available for that individual from that chip. We use greater than 3% as a cut off for our our low coverage samples and greater than 3.5% for our exome samples.',
    LC_Indel_Ratio='Both Indel ratios are the ratio of insertions to deletions found in that sample using a quick test (based on samtools). If the ratio is higher than 5 the sample is withdrawn.',
    E_Indel_Ratio='Both Indel ratios are the ratio of insertions to deletions found in that sample using a quick test (based on samtools). If the ratio is higher than 5 the sample is withdrawn.',
    LC_Passed_QC='These are binary flags showing if the sample passed QC, All samples which have passed QC have bam files. Only samples which have both exome and low coverage data are found under ftp/data and listed in the standard alignment index. The small number of other samples are found in ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/phase3_EX_or_LC_only_alignment/',
    E_Passed_QC='These are binary flags showing if the sample passed QC, All samples which have passed QC have bam files. Only samples which have both exome and low coverage data are found under ftp/data and listed in the standard alignment index. The small number of other samples are found in ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/phase3_EX_or_LC_only_alignment/',
    In_Final_Phase_Variant_Calling='Any sample which has both LC and E QC passed bams is in the final analysis set',
    Has_Omni_Genotypes='Omni Genotypes in ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20120131_omni_genotypes_and_intensities/Omni25_genotypes_2141_samples.b37.vcf.gz	',
    Has_Axiom_Genotypes='Axiom Genotypes in ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20110210_Affymetrix_Axiom/Affymetrix_Axiom_DB_2010_v4_b37.vcf.gz   	',
    Has_Affy_6_0_Genotypes='Affy 6.0 Genotypes in  ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20121128_corriel_p3_sample_genotypes/',
    Has_Exome_LOF_Genotypes='ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/working/20121009_broad_exome_chip/ALL.wgs.broad_exome_lof_indel_v2.20121009.snps_and_indels.snpchip.genotypes.vcf.gz',
    EBV_Coverage='This was calculated by looking at the alignment of the data to NC_007605 in the low coverage bam files and using that to calculate coverage	',
    DNA_Source_from_Coriell='This was the annotated DNA Source from Coriell	',
    Has_Sequence_from_Blood_in_Index='In the later stages of the project some populations has multiple study ids, one to indicate sequencing from blood. This data for each sample has not been treated independently in the alignment process but when there is both LCL and Blood sourced data they are both together in single bams',
    Super_Population='From ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.superpopulations.tsv',
    Super_Population_Description='From ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/20131219.superpopulations.tsv'    
    )

# Generate BQ Schema
cols = colnames(data)
empty_ints = c(NA)
bool_ints = c(0, 1, NA)
to_drop = c()
schema = c()
for (i in 1:length(cols)) {
    type = 'STRING'
    if('logical' == class(data[,i])) {
        type = 'BOOLEAN'
        if(setequal(empty_ints, union(empty_ints, data[,i]))) {
            to_drop = append(to_drop, cols[i])
            print(paste('DROPPING', cols[i]))
            next
        }
    } else if ('numeric' == class(data[,i])) {
        type = 'FLOAT'
    } else if ('integer' == class(data[,i])) {
        if(setequal(bool_ints, union(bool_ints, data[,i]))) {
            type = 'BOOLEAN'
        } else {
            type = 'INTEGER'
        }
    }
    schema = append(schema, paste("{'name':'", cols[i],"', 'type':'", type, "', 'description':'", description[[cols[i]]], "'}", sep="", collapse=","))
}
print(paste(schema, collapse=','))

# Drop empty columns
cleaned_data = data[,!(names(data) %in% to_drop)]

# Spot check our result
expect_that(subset(cleaned_data, Sample == 'HG00114', select=Total_Exome_Sequence)[1,1], equals(10374134700))
expect_that(subset(cleaned_data, Sample == 'HG00114', select=EBV_Coverage)[1,1], equals(10.78))

# Write out file to load into BigQuery
write.csv(cleaned_data, file.path(data_dir, 'pheno_pop.csv'), row.names=FALSE, na="")

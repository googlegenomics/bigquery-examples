Provenance
========================================================

Variant Data
------------------------------

Source:
* Google Cloud Storage gs://pgp-harvard-data-public/ which is a subset of https://my.pgp-hms.org/public_genetic_data?utf8=%E2%9C%93&data_type=Complete+Genomics&commit=Search
* _Note that one participant has been sequenced twice:_
 1. gs://pgp-harvard-data-public/hu34D5B9/GS000012763-DID/
 1. gs://pgp-harvard-data-public/hu34D5B9/GS000018040-DID/

Description:
* http://www.completegenomics.com/FAQs/
* http://www.completegenomics.com/FAQs/Working-with-the-Data/#q1
* http://www.completegenomics.com/customer-support/documentation/DataFileFormats-100357139.html
* http://www.completegenomics.com/FAQs/Variant-Calls-SNPs-and-Small-Indels/
* _Note that VCF positions 1-based but CGI positions 0-based_

CGI Version Information:
* extracted from the masterVarBeta-[ASM-ID].tsv.bz2 headers using Hadoop Streaming script [cgi-header-mapper.py](cgi-header-mapper.py) via [Hadoop on Google Cloud Platform](https://developers.google.com/hadoop/) with command line: `./bin/hadoop jar contrib/streaming/hadoop-streaming-1.2.1.jar -input gs://pgp-harvard-data-public/hu*/*/*/*/ASM/var* -mapper /home/$USER/cgi-header-mapper.py -file /home/$USER/cgi-header-mapper.py -reducer aggregate --numReduceTasks 1 -output gs://<output bucket>` producing output:

```
~/>cat part-00000 | grep -v GENERA | grep -v SAMPLE | grep -v ASSEM
#CNV_DIPLOID_WINDOW_WIDTH 2000  174
#CNV_NONDIPLOID_WINDOW_WIDTH 100000	174
#COSMIC COSMIC v48	174
#DBSNP_BUILD dbSNP build 132	174
#DGV_VERSION 9	174
#FORMAT_VERSION 2.0	174
#GENE_ANNOTATIONS NCBI build 37.2	174
#GENOME_REFERENCE NCBI build 37	174
#MIRBASE_VERSION miRBase version 16	174
#PFAM_DATE April 21, 2011	174
#SOFTWARE_VERSION 2.0.2.26	5
#SOFTWARE_VERSION 2.0.3.2	8
#SOFTWARE_VERSION 2.0.3.3	16
#SOFTWARE_VERSION 2.0.3.5	5
#SOFTWARE_VERSION 2.0.3.6	16
#SOFTWARE_VERSION 2.0.4.11	1
#SOFTWARE_VERSION 2.0.4.14	102
#SOFTWARE_VERSION 2.0.4.18	20
#SOFTWARE_VERSION 2.0.4.8	1
#TYPE VAR-OLPL	174
```

### calls table

Data was loaded from the master variations files "a simple, integrated report of the variant calls and annotation information produced by the Complete Genomics assembly process".

1. Specifically, the masterVarBeta-[ASM-ID].tsv.bz2 file for 174 of the 175 CGI genomes in Google Cloud Storage bucket gs://pgp-harvard-data-public were transformed to add an additional column containing the PGP Participant identifier using Hadoop Streaming script [cgi-mapper.py](cgi-mapper.py) via [Hadoop on Google Cloud Platform](https://developers.google.com/hadoop/) with command line:
```
./bin/hadoop jar contrib/streaming/hadoop-streaming-1.2.1.jar -input gs://pgp-harvard-data-public/hu*/*/*/*/ASM/master* -mapper /home/$USER/cgi-mapper.py -file /home/$USER/cgi-mapper.py --numReduceTasks 0 -output gs://<output bucket>
```

1. The BigQuery schema was auto-generated using script [cgi-calls-prep.R](cgi-calls-prep.R)

1. The tab-separated values output by this Hadoop Streaming job were then imported directly to BigQuery via the [BigQuery Browser Tool](https://developers.google.com/bigquery/bigquery-browser-tool#createtable).

### variants table

1. 172 of the 175 CGI genomes in Google Cloud Storage bucket gs://pgp-harvard-data-public were converted from native format to VCF via [Complete Genomics Analysis Tools](http://www.completegenomics.com/analysis-tools/cgatools/) [mkvcf](http://www.google.com/url?q=http%3A%2F%2Fcgatools.sourceforge.net%2Fdocs%2F1.8.0%2Fcgatools-command-line-reference.html%23mkvcf&sa=D&sntz=1&usg=AFQjCNGWkNsJIVWoTqn81tM77abZr5J1aQ) with command line: 
```
cgatools mkvcf --beta --reference <reference> --genome-root <dir> --output <vcf output file> --field_names GT,PS,NS,AN,AC,AF,SS,FT,CGA_XR,CGA_ALTCALLS,CGA_FI,GQ,HQ,EHQ,GL,DP,AD,CGA_RDP,CGA_ODP,CGA_OAD,CGA_ORDP,CGA_PFAM,CGA_MIRB,CGA_RPT,CGA_SDO,CGA_SOMC,CGA_SOMR,CGA_SOMS,CGA_SOMF,GT,CGA_GP,CGA_NP,CGA_CP,CGA_PS,CGA_CT,CGA_TS,CGA_CL,CGA_LS,CGA_LAFS,CGA_LLAFS,CGA_ULAFS,CGA_SCL,CGA_SLS,CGA_LAFP,CGA_LLAFP,CGA_ULAFP,GT,FT,CGA_IS,CGA_IDC,CGA_IDCL,CGA_IDCR,CGA_RDC,CGA_NBET,CGA_ETS,CGA_KES,GT,FT,CGA_BF,CGA_MEDEL,MATEID,SVTYPE,CGA_BNDG,CGA_BNDGO,CGA_BNDMPC,CGA_BNDPOS,CGA_BNDDEF,CGA_BNDP
```

1. These VCFs were then [imported](https://developers.google.com/genomics/v1beta/reference/variants/import) to Google Genomics.  The import process creates the following added and derived values:
   * `call.callset_id` is an system identifier
   * `end_pos` is computed from POSTIION and REF in the source VCF data

1. The variants were then [exported](https://developers.google.com/genomics/v1beta/reference/variants/export) from Google Genomics to BigQuery

Phenotypic Data
------------------

### phenotypes table

Source: 
* https://my.pgp-hms.org/google_surveys
* Date Downloaded: May 6, 2014

Status: 
* complete, see script [phenotype-prep.R](phenotype-prep.R) to see how the data was cleaned and transformed prior to the upload to BigQuery
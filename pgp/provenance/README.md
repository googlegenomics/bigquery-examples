Provenance
========================================================

Source Variant Data
------------------------------

### variants table

Description:
* http://www.completegenomics.com/FAQs/Variant-Calls-SNPs-and-Small-Indels/

Source:
* https://my.pgp-hms.org/public_genetic_data?utf8=%E2%9C%93&data_type=Complete+Genomics&commit=Search

Files:
* 172 of the 174 CGI genomes in Google Cloud Storage bucket gs://pgp-harvard-data-public were converted from native format to VCF via [Complete Genomics Analysis Tools](http://www.completegenomics.com/analysis-tools/cgatools/) [mkvcf](http://www.google.com/url?q=http%3A%2F%2Fcgatools.sourceforge.net%2Fdocs%2F1.8.0%2Fcgatools-command-line-reference.html%23mkvcf&sa=D&sntz=1&usg=AFQjCNGWkNsJIVWoTqn81tM77abZr5J1aQ) with command line: 

```
cgatools mkvcf --beta --reference <reference> --genome-root <dir> --output <vcf output file> --field_names GT,PS,NS,AN,AC,AF,SS,FT,CGA_XR,CGA_ALTCALLS,CGA_FI,GQ,HQ,EHQ,GL,DP,AD,CGA_RDP,CGA_ODP,CGA_OAD,CGA_ORDP,CGA_PFAM,CGA_MIRB,CGA_RPT,CGA_SDO,CGA_SOMC,CGA_SOMR,CGA_SOMS,CGA_SOMF,GT,CGA_GP,CGA_NP,CGA_CP,CGA_PS,CGA_CT,CGA_TS,CGA_CL,CGA_LS,CGA_LAFS,CGA_LLAFS,CGA_ULAFS,CGA_SCL,CGA_SLS,CGA_LAFP,CGA_LLAFP,CGA_ULAFP,GT,FT,CGA_IS,CGA_IDC,CGA_IDCL,CGA_IDCR,CGA_RDC,CGA_NBET,CGA_ETS,CGA_KES,GT,FT,CGA_BF,CGA_MEDEL,MATEID,SVTYPE,CGA_BNDG,CGA_BNDGO,CGA_BNDMPC,CGA_BNDPOS,CGA_BNDDEF,CGA_BNDP
```
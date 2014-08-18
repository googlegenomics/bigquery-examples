# Sample level data for Klotho variant rs9536314 for use in the "amazing
# intelligence of PGP participants" data story, specifically joining two 
# tables to compare the different encodings.
SELECT
  cgi.sample_id,
  chromosome,
  locusBegin,
  locusEnd,
  reference,
  allele1Seq,
  allele2Seq,
  contig_name,
  start_pos,
  end_pos,
  END,
  ref,
  alt,
  gvcf.sample_id,
  genotype
FROM
  [google.com:biggene:pgp.cgi_variants] AS cgi
  left OUTER JOIN
  (
  SELECT
    contig_name,
    start_pos,
    end_pos,
    END,
    ref,
    alt,
    sample_id,
    genotype
  FROM
    FLATTEN(
    SELECT
      contig_name,
      start_pos,
      end_pos,
      END,
      reference_bases AS ref,
      GROUP_CONCAT(alternate_bases) WITHIN RECORD AS alt,
      call.callset_name AS sample_id,
      GROUP_CONCAT(STRING(call.genotype),
        '/') WITHIN call AS genotype,
    FROM
      [google.com:biggene:pgp.gvcf_variants]
    WHERE
      contig_name = '13'
      AND start_pos <= 33628138
      AND (end_pos >= 33628139
        OR END >= 33628139)
      ,
      call)) AS gvcf
ON
  cgi.sample_id = gvcf.sample_id
WHERE
  chromosome = "chr13"
  AND locusBegin <= 33628137
  AND locusEnd >= 33628138
  # Skip the genomes we were unable to convert to VCF/gVCF
OMIT RECORD IF 
  cgi.sample_id = 'huEDF7DA' OR cgi.sample_id = 'hu34D5B9'
ORDER BY
  cgi.sample_id

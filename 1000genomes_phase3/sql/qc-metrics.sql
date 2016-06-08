# Compute several common metrics on multi-allelic data in "multi-sample variants" format
# http://googlegenomics.readthedocs.io/en/latest/use_cases/load_data/multi_sample_variants.html
#
# Edit the BigQuery table name below to run this query on other data in multi-sample variants format
# such as 1,000 Genomes phase 1 variants.
# http://googlegenomics.readthedocs.io/en/latest/use_cases/discover_public_data/1000_genomes.html
#
SELECT
  call.call_set_name,
  # Ratios.
  transitions_count / transversions_count AS ti_tv_ratio,
  (het_RA_count + het_AA_count) / (hom_RR_count + hom_AA_count) AS het_hom_ratio,
  insertion_count / deletion_count AS ins_del_ratio,
  # Call type counts.
  hom_RR_count,
  hom_AA_count,
  het_RA_count,
  het_AA_count,
  # Alternate allele type counts.
  sv_count,
  snp_count,
  expanded_snp_count,
  insertion_count,
  deletion_count,
  # SNP type counts.
  transitions_count,
  transversions_count,
  # Let's check our work for over/under counting.
  calls_has_alternate_bases_count,
  transitions_count + transversions_count AS check_snp_count,
  sv_count + snp_count + expanded_snp_count + insertion_count + deletion_count AS check_calls_has_alternate_bases_count,
  hom_RR_count + hom_AA_count + het_RA_count + het_AA_count AS check_total_num_calls,
FROM (
  SELECT
    call.call_set_name,
    SUM(is_hom_RR) AS hom_RR_count,
    SUM(is_hom_AA) AS hom_AA_count,
    SUM(is_het_RA) AS het_RA_count,
    # Divide by het_AA two since we have two rows for this sample's alleles because we FLATTENED by alt.
    SUM(is_het_AA)/2 AS het_AA_count,
    SUM(call_has_alternate_bases) AS calls_has_alternate_bases_count,
    SUM(call_has_alternate_bases AND is_sv) AS sv_count,
    SUM(call_has_alternate_bases AND is_snp) AS snp_count,
    SUM(call_has_alternate_bases AND is_expanded_snp) AS expanded_snp_count,
    SUM(call_has_alternate_bases AND is_insertion) AS insertion_count,
    SUM(call_has_alternate_bases AND is_deletion) AS deletion_count,
    SUM(call_has_alternate_bases AND is_transition) AS transitions_count,
    SUM(call_has_alternate_bases AND is_transversion) AS transversions_count,
  FROM (
    SELECT
      call.call_set_name,
      # Anchor on alt=1 so that we don't over count multi-allelic sites.
      alt = 1 AND reference_match_call AS is_hom_RR,
      first_allele = alt OR second_allele = alt AS call_has_alternate_bases,
      first_allele = alt AND (second_allele = alt OR second_allele IS NULL) AS is_hom_AA,
      (first_allele = 0 AND second_allele = alt) OR (first_allele = alt AND second_allele = 0) AS is_het_RA,
      (first_allele > 0 AND first_allele != alt AND second_allele = alt)
        OR (first_allele = alt AND second_allele > 0 AND second_allele != alt) AS is_het_AA,
      NOT is_sequence AS is_sv,
      is_sequence AND LENGTH(reference_bases) = 1 AND LENGTH(alternate_bases) = 1 AS is_snp,
      is_sequence AND LENGTH(reference_bases) > 1 AND LENGTH(reference_bases) = LENGTH(alternate_bases) AS is_expanded_snp,
      is_sequence AND LENGTH(reference_bases) < LENGTH(alternate_bases) AS is_insertion,
      is_sequence AND LENGTH(reference_bases) > LENGTH(alternate_bases) AS is_deletion,
      mutation IN ('A->G','G->A','C->T','T->C') AS is_transition,
      mutation IN ('A->C','C->A','G->T','T->G','A->T','T->A','C->G','G->C') AS is_transversion,
    FROM (
      SELECT
        call.call_set_name,
        reference_name,
        start,
        reference_bases,
        alternate_bases,
        CONCAT(reference_bases, CONCAT(STRING('->'), alternate_bases)) AS mutation,
        REGEXP_MATCH(alternate_bases, r'^[A,C,G,T]+$') AS is_sequence,
        alt,
        reference_match_call,
        first_allele,
        second_allele,
      FROM
        # 1,000 Genomes phase 3 is multi-allelic so we need to take in to account the alternate number.
        # Be careful with the analyses that wrap this because this double FLATTEN is giving us the cross
        # product of 'alternate_bases' and 'call'.
        FLATTEN( FLATTEN((
            SELECT
              reference_name,
              start,
              reference_bases,
              alternate_bases,
              POSITION(alternate_bases) AS alt,  # Get the number corresponding to the alternate_bases value.
              call.call_set_name,
              EVERY(call.genotype = 0) WITHIN call AS reference_match_call,
              NTH(1, call.genotype) WITHIN call AS first_allele,
              NTH(2, call.genotype) WITHIN call AS second_allele,
            FROM
              # To run on phase 1 variants, update the following line to change the source table.
              [genomics-public-data:1000_genomes_phase_3.variants_20150220_release]
            # Use this WHERE clause for fast testing of the query. Remove it for the full analysis.
            # WHERE
            #   reference_name = '17'
            #   AND start BETWEEN 41196311
            #   AND 41277499
         ), call), alt)))
  GROUP BY
    call.call_set_name
  ORDER BY
    call.call_set_name)

# Count the number of INDELs differing from the reference allele by particular lengths
SELECT
  length_difference,
  COUNT(length_difference) AS count_of_indels_with_length_difference,
FROM (
  SELECT
    reference_name,
    start,
    reference_bases,
    LENGTH(reference_bases) AS ref_length,
    alternate_bases AS allele,
    LENGTH(alternate_bases) AS allele_length,
    (LENGTH(alternate_bases) - LENGTH(reference_bases)) AS length_difference,
    FROM
      [genomics-public-data:1000_genomes.variants]
    WHERE
      vt ='INDEL'
    )
GROUP BY
  length_difference
ORDER BY
  length_difference

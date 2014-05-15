# Compute sample count by gender
SELECT
  Sex_Gender,
  COUNT(1) AS cnt
FROM
  (
  SELECT
    call.callset_name,
    Sex_Gender
  FROM
    FLATTEN([google.com:biggene:pgp.variants],
      call) AS var
  JOIN
    [google.com:biggene:pgp.phenotypes] AS pheno
  ON
    pheno.Participant = var.call.callset_name
  GROUP BY
    call.callset_name,
    Sex_Gender)
GROUP BY
  Sex_Gender
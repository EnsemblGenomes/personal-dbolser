

#SET @evalue := 10;
SET @evalue := 1e-3;
#SET @evalue := 1e-6;
#SET @evalue := 1e-9;

SET @logic_name := 'cmscan_rfam_12.2';
#SET @logic_name := 'cmscan_rfam_12.2_lca';

#SELECT @evalue, @logic_name;

SELECT
  @avg := AVG(N),
  @std := STD(N)
FROM (
  SELECT
    logic_name, hit_name, COUNT(*) AS N
  FROM
    dna_align_feature
  INNER JOIN
    analysis USING (analysis_id)
  WHERE
    logic_name = @logic_name
  AND
    evalue < @evalue
  GROUP BY
    analysis_id, hit_name
) AS
  x
;

#SELECT @avg, @std;

SELECT
  @logic_name, @evalue, @avg, @std, @avg + (@std * 2) AS sig,
  x.*
FROM (
  SELECT
    logic_name, hit_name, COUNT(*) AS N
  FROM
    dna_align_feature
  INNER JOIN
    analysis USING (analysis_id)
  WHERE
    logic_name = @logic_name
  AND
    evalue < @evalue
  GROUP BY
    analysis_id, hit_name
) AS
  x
HAVING
  N > sig
;








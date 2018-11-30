--
-- Repeat from here as required...
--

-- I honestly can't work out why this is necessary each
-- itteration and not just once in the beginning
UPDATE exon_bk SET exon_id2 = exon_id;

-- Get a list of dupes
DROP  TABLE IF EXISTS temp_duplicate_exons;
CREATE          TABLE temp_duplicate_exons (
  PRIMARY KEY (exon_id)
) AS
--
SELECT
  exon_id,
  -- Pick the transcript we'll link the new exon to below here for
  -- convenience...
  MAX(transcript_id) AS transcript_id
FROM
  exon_transcript_bk
-- HO HO
INNER JOIN
  temp_problem_exons
USING
  (exon_id)
--
GROUP BY
  exon_id
HAVING
  COUNT(*) > 1
;

-- Sanity test, both counts should be equal
SELECT COUNT(*) FROM temp_duplicate_exons;

SELECT COUNT(*) FROM temp_duplicate_exons
INNER JOIN exon_bk USING (exon_id)
INNER JOIN exon_transcript_bk
USING (exon_id, transcript_id);

-- Clone the dupes (all fields except exon_id, because we're
-- intentionally handing out new IDs)
INSERT INTO exon_bk (
  seq_region_id, seq_region_start, seq_region_end, seq_region_strand,
  phase, end_phase, is_current, is_constitutive, stable_id, version,
  created_date, modified_date, exon_id2
)
SELECT
  seq_region_id, seq_region_start, seq_region_end, seq_region_strand,
  phase, end_phase, is_current, is_constitutive, stable_id, version,
  created_date, modified_date, exon_id2
FROM
  exon_bk
INNER JOIN
  temp_duplicate_exons
USING
  (exon_id)
;

-- Now re-link the dupes in the exon_transcript table...
UPDATE
  temp_duplicate_exons x
INNER JOIN
  exon_bk a USING (exon_id)
INNER JOIN
  exon_bk b
ON -- Link via the old ID, returning the new row...
  a.exon_id2 = b.exon_id2 AND a.exon_id != b.exon_id
INNER JOIN
  exon_transcript_bk et
ON
  a.exon_id = et.exon_id
AND
  x.transcript_id = et.transcript_id
SET
  et.exon_id = b.exon_id
;

-- You didn't forget this table now did you?
UPDATE
  translation_bk t
INNER JOIN
  exon_bk
ON -- Link to the old ID, for the updated row...
  start_exon_id = exon_id2 AND exon_id2 != exon_id
INNER JOIN
  exon_transcript_bk et
USING
  (exon_id, transcript_id)
SET
  start_exon_id = exon_id
;

UPDATE
  translation_bk t
INNER JOIN
  exon_bk
ON -- Link to the old ID, for the updated row...
  end_exon_id = exon_id2 AND exon_id2 != exon_id
INNER JOIN
  exon_transcript_bk et
USING
  (exon_id, transcript_id)
SET
  end_exon_id = exon_id
;

-- Now repeat from above as required, as some exons are shared between
-- more than just two transcripts...

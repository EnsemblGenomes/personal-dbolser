
CREATE   TABLE translation_bk LIKE translation;
INSERT   INTO  translation_bk SELECT * FROM translation;

# UNDO
TRUNCATE TABLE translation;
INSERT   INTO  translation SELECT * FROM translation_bk

# +3
UPDATE stops_to_fix
INNER JOIN transcript  USING (stable_id)
INNER JOIN translation USING (transcript_id)
SET seq_end = seq_end+3;

# Look at over-runs
SELECT COUNT(*) FROM (
  SELECT seq_region_end-seq_region_start+1 AS exon_len,
  seq_end, seq_region_strand AS exon_strand FROM translation t
  INNER JOIN exon e ON exon_id = end_exon_id
  HAVING exon_len < seq_end
) AS x;

DROP             TABLE temp_exon_over;
CREATE TEMPORARY TABLE temp_exon_over (
  UNIQUE INDEX (exon_id), PRIMARY KEY (transcript_id)
) AS
SELECT
  exon_id, transcript_id,
  seq_region_end - seq_region_start + 1 AS exon_len,
  seq_end,
  seq_region_strand AS exon_strand
FROM
  translation t
INNER JOIN
  exon e ON exon_id = end_exon_id
HAVING
  exon_len < seq_end;

# -3 where we  over-ran
UPDATE translation
INNER JOIN exon ON exon_id = end_exon_id
SET seq_end = seq_end - 3
WHERE seq_region_end-seq_region_start+1 < seq_end;

# Look at 'weird cases' (we need to fix manually)
CREATE TEMPORARY TABLE temp_pukus (
  PRIMARY KEY (transcript_id)
) AS
SELECT
  o.transcript_id, e.rank, MAX(t.rank) AS xxx
FROM temp_exon_over o
INNER JOIN exon_transcript e ON o.exon_id = e.exon_id
INNER JOIN exon_transcript t ON o.transcript_id = t.transcript_id
GROUP BY o.transcript_id HAVING xxx > e.rank;

# Ignore them for now...
DELETE temp_exon_over
FROM temp_exon_over
INNER JOIN temp_pukus USING (transcript_id);

# Sigh...
SELECT
  tl.seq_end,
  ts.seq_region_start,
  #ts.seq_region_end,
  #ts.seq_region_strand,
  ex.seq_region_start,
  #ex.seq_region_end,
  #ex.seq_region_strand,
  ge.seq_region_start#,
  #ge.seq_region_end,
  #ge.seq_region_strand
FROM
  temp_exon_over x
INNER JOIN transcript  ts USING (transcript_id)
INNER JOIN translation tl USING (transcript_id)
INNER JOIN exon ex        USING (exon_id)
INNER JOIN gene ge        USING (gene_id)
WHERE
  ex.seq_region_strand = -1
LIMIT 03
;

# Here goes...

CREATE   TABLE transcript_bk LIKE transcript;
INSERT   INTO  transcript_bk SELECT * FROM transcript;

CREATE   TABLE exon_bk LIKE exon;
INSERT   INTO  exon_bk SELECT * FROM exon;


UPDATE temp_exon_over x
INNER JOIN transcript  ts USING (transcript_id)
INNER JOIN translation tl USING (transcript_id)
INNER JOIN exon ex        USING (exon_id)
SET
  tl.seq_end        = tl.seq_end        + 3,
  ts.seq_region_end = ts.seq_region_end + (x.seq_end - exon_len),
  ex.seq_region_end = ex.seq_region_end + (x.seq_end - exon_len)
WHERE
  ex.seq_region_strand = 1
;

UPDATE temp_exon_over x
INNER JOIN transcript  ts USING (transcript_id)
INNER JOIN translation tl USING (transcript_id)
INNER JOIN exon ex        USING (exon_id)
SET
  tl.seq_end          = tl.seq_end          + 3,
  ts.seq_region_start = ts.seq_region_start - (x.seq_end - exon_len),
  ex.seq_region_start = ex.seq_region_start - (x.seq_end - exon_len)
WHERE
  ex.seq_region_strand = -1
;

## I HATE LIFE
CREATE   TABLE gene_bk LIKE gene;
INSERT   INTO  gene_bk SELECT * FROM gene;

UPDATE transcript t
INNER JOIN gene g USING (gene_id)
SET g.seq_region_end = t.seq_region_end
WHERE t.seq_region_end > g.seq_region_end
AND t.seq_region_strand = 1;

UPDATE transcript t
INNER JOIN gene g USING (gene_id)
SET g.seq_region_start = t.seq_region_start
WHERE t.seq_region_start < g.seq_region_start
AND t.seq_region_strand = -1;





# FFFFFFFFFFFFFFFFFFFFFFFf

RENAME TABLE exon TO exon_rm;
RENAME TABLE exon_bk TO exon;

RENAME TABLE transcript TO transcript_rm;
RENAME TABLE transcript_bk TO transcript;

RENAME TABLE translation TO translation_rm;
RENAME TABLE translation_bk TO translation;

RENAME TABLE gene TO gene_rm;
RENAME TABLE gene_bk TO gene;


DROP TABLE exon_rm, transcript_rm, translation_rm, gene_rm;
DROP TABLE gene_rm;



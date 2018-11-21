
SELECT
  asm.seq_region_id,
  asm.name,
  asm.coord_system_id,
  asm.length,
  MAX(asm_end) AS MAX_ASM
FROM
  assembly
INNER JOIN
  seq_region asm ON
    asm.seq_region_id =
    asm_seq_region_id
INNER JOIN
  seq_region_attrib
USING
  (seq_region_id)
INNER JOIN
  attrib_type
USING
  (attrib_type_id)
WHERE
  code = 'toplevel'
GROUP BY
  asm.seq_region_id
HAVING
  MAX_ASM != asm.length
;

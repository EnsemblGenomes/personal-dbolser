
-- SELECT
--   COUNT(*),
--   casm.*,
--   ccmp.*
-- FROM
--   assembly
-- --
-- INNER JOIN
--   seq_region asm
-- ON
--   asm.seq_region_id =
--   asm_seq_region_id
-- INNER JOIN 
--   coord_system casm
-- ON
--   asm.coord_system_id =
--  casm.coord_system_id
-- --
-- INNER JOIN
--   seq_region cmp
-- ON
--   cmp.seq_region_id =
--   cmp_seq_region_id
-- INNER JOIN
--   coord_system ccmp
-- ON
--   cmp.coord_system_id =
--  ccmp.coord_system_id
-- --
-- GROUP BY
--   asm.coord_system_id,
--   cmp.coord_system_id
-- ;

SELECT
  assembly.*
FROM
  assembly
--
INNER JOIN
  seq_region asm
ON
  asm.seq_region_id =
  asm_seq_region_id
INNER JOIN 
  coord_system casm
ON
  asm.coord_system_id =
 casm.coord_system_id
--
INNER JOIN
  seq_region cmp
ON
  cmp.seq_region_id =
  cmp_seq_region_id
INNER JOIN
  coord_system ccmp
ON
  cmp.coord_system_id =
 ccmp.coord_system_id
--
WHERE
  ccmp.version !=
  casm.version
--
-- AND
--   asm_seq_region_id = 2808
ORDER BY
  cmp_end -
  cmp_start DESC
-- LIMIT
-- 100
;



SELECT * FROM xref  GROUP BY dbprimary_acc, external_db_id, info_type, info_text HAVING COUNT(*)>1;

SELECT * FROM xref WHERE xref_id IN (
  2123213, 2117133, 2145056, 2142309,
  2146440, 2123172, 2114968, 2131720,
  2147854, 2141835, 2139633, 2115106,
  2134375, 2119109, 2119825, 2150405,
  2302134, 2299808, 2310473, 2305672,
  2311070, 2302112, 2298991, 2305392,
  2311589, 2309246, 2308380, 2299047,
  2306361, 2300599, 2300853, 2312545
) ORDER BY dbprimary_acc;

+-----------+------------------+-----------------+-----------------+-----------+-------------------------------------------------------------------------------+-------------+-------------+
|   xref_id |   external_db_id | dbprimary_acc   | display_label   |   version | description                                                                   | info_type   | info_text   |
|-----------+------------------+-----------------+-----------------+-----------+-------------------------------------------------------------------------------+-------------+-------------|
|   2123213 |             2000 | B3H674          | B3H674          |         1 | <null>                                                                        | DEPENDENT   |             |
|   2302134 |             2000 | B3H674          | B3H674          |         2 | Alternative NAD(P)H dehydrogenase                                             | DEPENDENT   |             |

|   2117133 |             2000 | B6EUB6          | B6EUB6          |         1 | Nuclear transcription factor Y subunit B-1                                    | DEPENDENT   |             |
|   2299808 |             2000 | B6EUB6          | B6EUB6          |         2 | Nuclear factor Y, subunit B1                                                  | DEPENDENT   |             |

|   2145056 |             2000 | F4HTC5          | F4HTC5          |         1 | 26S protease regulatory subunit 7-like B                                      | DEPENDENT   |             |
|   2310473 |             2000 | F4HTC5          | F4HTC5          |         2 | 26S proteasome regulatory complex ATPase                                      | DEPENDENT   |             |

|   2142309 |             2000 | F4HTE0          | F4HTE0          |         1 | Eukaryotic translation initiation factor 2B-like protein                      | DEPENDENT   |             |
|   2305672 |             2000 | F4HTE0          | F4HTE0          |         2 | Translation initiation factor eIF-2B subunit alpha                            | DEPENDENT   |             |

|   2146440 |             2000 | F4HXG0          | F4HXG0          |         1 | <null>                                                                        | DEPENDENT   |             |
|   2311070 |             2000 | F4HXG0          | F4HXG0          |         2 | DNA ligase-like protein                                                       | DEPENDENT   |             |

|   2123172 |             2000 | F4I3J1          | F4I3J1          |         1 | <null>                                                                        | DEPENDENT   |             |
|   2302112 |             2000 | F4I3J1          | F4I3J1          |         2 | Cysteine-rich/transmembrane domain protein B                                  | DEPENDENT   |             |

|   2114968 |             2000 | F4I6D2          | F4I6D2          |         1 | S-adenosyl-L-methionine-dependent methyltransferase domain-containing protein | DEPENDENT   |             |
|   2298991 |             2000 | F4I6D2          | F4I6D2          |         2 | S-adenosyl-L-methionine-dependent methyltransferase superfamily protein       | DEPENDENT   |             |

|   2131720 |             2000 | F4IEJ8          | F4IEJ8          |         1 | Alpha/beta-Hydrolases superfamily protein                                     | DEPENDENT   |             |
|   2305392 |             2000 | F4IEJ8          | F4IEJ8          |         2 | Alpha/beta-Hydrolases superfamily protein                                     | DEPENDENT   |             |

|   2147854 |             2000 | F4IFS4          | F4IFS4          |         1 | N-acetylglucosaminylphosphatidylinositol de-N-acetylase family protein        | DEPENDENT   |             |
|   2311589 |             2000 | F4IFS4          | F4IFS4          |         2 | N-acetylglucosaminylphosphatidylinositol de-N-acetylase family protein        | DEPENDENT   |             |

|   2141835 |             2000 | F4IVY7          | F4IVY7          |         1 | <null>                                                                        | DEPENDENT   |             |
|   2309246 |             2000 | F4IVY7          | F4IVY7          |         2 | <null>                                                                        | DEPENDENT   |             |

|   2139633 |             2000 | F4JQ53          | F4JQ53          |         1 | Thaumatin-like protein 1                                                      | DEPENDENT   |             |
|   2308380 |             2000 | F4JQ53          | F4JQ53          |         2 | THAUMATIN-LIKE PROTEIN 1                                                      | DEPENDENT   |             |

|   2115106 |             2000 | F4JV54          | F4JV54          |         1 | Phosphoinositide binding protein                                              | DEPENDENT   |             |
|   2299047 |             2000 | F4JV54          | F4JV54          |         2 | Phosphoinositide binding protein                                              | DEPENDENT   |             |

|   2134375 |             2000 | F4K382          | F4K382          |         1 | TIR-NBS class disease resistance protein                                      | DEPENDENT   |             |
|   2306361 |             2000 | F4K382          | F4K382          |         2 | Disease resistance protein (TIR-NBS class)                                    | DEPENDENT   |             |

|   2119109 |             2000 | F4K718          | F4K718          |         1 | Putative serine/threonine-protein kinase WNK9                                 | DEPENDENT   |             |
|   2300599 |             2000 | F4K718          | F4K718          |         2 | Protein kinase superfamily protein                                            | DEPENDENT   |             |

|   2119825 |             2000 | F4KEN7          | F4KEN7          |         1 | Leucine-rich repeat protein kinase family protein                             | DEPENDENT   |             |
|   2300853 |             2000 | F4KEN7          | F4KEN7          |         2 | Leucine-rich repeat protein kinase family protein                             | DEPENDENT   |             |

|   2150405 |             2000 | F4KEP6          | F4KEP6          |         1 | Protein agamous-like 71                                                       | DEPENDENT   |             |
|   2312545 |             2000 | F4KEP6          | F4KEP6          |         2 | AGAMOUS-like 71                                                               | DEPENDENT   |             |

+-----------+------------------+-----------------+-----------------+-----------+-------------------------------------------------------------------------------+-------------+-------------+
32 rows in set


SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2123213, 2302134) AND table_name NOT IN ('xref'); # | 2302134 | 2302134
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2117133, 2299808) AND table_name NOT IN ('xref'); # | 2299808 | 2299808
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2145056, 2310473) AND table_name NOT IN ('xref'); # | 2310473 | 2310473
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2142309, 2305672) AND table_name NOT IN ('xref'); # | 2305672 | 2305672
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2146440, 2311070) AND table_name NOT IN ('xref'); # | 2311070 | 2311070
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2123172, 2302112) AND table_name NOT IN ('xref'); # | 2302112 | 2302112
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2114968, 2298991) AND table_name NOT IN ('xref'); # | 2298991 | 2298991
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2131720, 2305392) AND table_name NOT IN ('xref'); # | 2305392 | 2305392
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2147854, 2311589) AND table_name NOT IN ('xref'); # | 2311589 | 2311589
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2141835, 2309246) AND table_name NOT IN ('xref'); # | 2309246 | 2309246
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2139633, 2308380) AND table_name NOT IN ('xref'); # | 2308380 | 2308380
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2115106, 2299047) AND table_name NOT IN ('xref'); # | 2299047 | 2299047
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2134375, 2306361) AND table_name NOT IN ('xref'); # | 2306361 | 2306361
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2119109, 2300599) AND table_name NOT IN ('xref'); # | 2300599 | 2300599
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2119825, 2300853) AND table_name NOT IN ('xref'); # | 2300853 | 2300853
SELECT DISTINCT value FROM test.temp_distinct_values WHERE value IN (2150405, 2312545) AND table_name NOT IN ('xref'); # | 2312545 | 2312545

DELETE FROM xref WHERE xref_id = 2123213;
DELETE FROM xref WHERE xref_id = 2117133;
DELETE FROM xref WHERE xref_id = 2145056;
DELETE FROM xref WHERE xref_id = 2142309;
DELETE FROM xref WHERE xref_id = 2146440;
DELETE FROM xref WHERE xref_id = 2123172;
DELETE FROM xref WHERE xref_id = 2114968;
DELETE FROM xref WHERE xref_id = 2131720;
DELETE FROM xref WHERE xref_id = 2147854;
DELETE FROM xref WHERE xref_id = 2141835;
DELETE FROM xref WHERE xref_id = 2139633;
DELETE FROM xref WHERE xref_id = 2115106;
DELETE FROM xref WHERE xref_id = 2134375;
DELETE FROM xref WHERE xref_id = 2119109;
DELETE FROM xref WHERE xref_id = 2119825;
DELETE FROM xref WHERE xref_id = 2150405;




-- MySQL dump 10.13  Distrib 5.1.73, for redhat-linux-gnu (x86_64)
--
-- Host: mysql-eg-mirror.ebi.ac.uk    Database: ensembl_compara_plants_32_85
-- ------------------------------------------------------
-- Server version	5.6.24

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Dumping data for table `synteny_region`
--
-- WHERE:  method_link_species_set_id IN (18729, 18806)

LOCK TABLES `synteny_region` WRITE;
/*!40000 ALTER TABLE `synteny_region` DISABLE KEYS */;
INSERT INTO `synteny_region` VALUES (930,18729),(931,18729),(932,18729),(933,18729),(934,18729),(935,18729),(936,18729),(937,18729),(938,18729),(939,18729),(940,18729),(941,18729),(942,18729),(943,18729),(944,18729),(945,18729),(946,18729),(947,18729),(948,18729),(949,18729),(950,18729),(951,18729),(952,18729),(953,18729),(954,18729),(955,18729),(956,18729),(957,18729),(958,18729),(959,18729),(960,18729),(961,18729),(962,18729),(963,18729),(964,18729),(965,18729),(966,18729),(967,18729),(968,18729),(969,18729),(970,18729),(971,18729),(972,18729),(973,18729),(974,18729),(975,18729),(976,18729),(977,18729),(978,18729),(979,18729),(980,18729),(981,18729),(982,18729),(983,18729),(984,18729),(985,18729),(986,18729),(987,18729),(988,18729),(989,18729),(990,18729),(991,18729),(992,18729),(993,18729),(994,18729),(995,18729),(996,18729),(997,18729),(998,18729),(999,18729),(1000,18729),(1001,18729),(1002,18729),(1003,18729),(1004,18729),(1005,18729),(1006,18729),(1007,18729),(1008,18729),(1009,18729),(1010,18729),(1011,18729),(1012,18729),(1013,18729),(1014,18729),(1015,18729),(1016,18729),(1017,18729),(1018,18729),(1019,18729),(1020,18729),(1021,18729),(1022,18729),(1023,18729),(1024,18729),(1025,18729),(1026,18729),(1027,18729),(1028,18729),(1029,18729),(734,18806),(735,18806),(736,18806),(737,18806),(738,18806),(739,18806),(740,18806),(741,18806),(742,18806),(743,18806),(744,18806),(745,18806),(746,18806),(747,18806),(748,18806),(749,18806),(750,18806),(751,18806),(752,18806),(753,18806),(754,18806),(755,18806),(756,18806),(757,18806),(758,18806),(759,18806),(760,18806),(761,18806),(762,18806),(763,18806),(764,18806),(765,18806),(766,18806),(767,18806),(768,18806),(769,18806),(770,18806),(771,18806),(772,18806),(773,18806),(774,18806),(775,18806),(776,18806),(777,18806),(778,18806),(779,18806),(780,18806),(781,18806),(782,18806),(783,18806),(784,18806),(785,18806),(786,18806),(787,18806),(788,18806),(789,18806),(790,18806),(791,18806),(792,18806),(793,18806),(794,18806),(795,18806),(796,18806),(797,18806),(798,18806),(799,18806),(800,18806),(801,18806),(802,18806),(803,18806),(804,18806),(805,18806),(806,18806),(807,18806),(808,18806),(809,18806),(810,18806),(811,18806),(812,18806),(813,18806),(814,18806),(815,18806),(816,18806),(817,18806),(818,18806),(819,18806),(820,18806),(821,18806),(822,18806),(823,18806),(824,18806),(825,18806),(826,18806),(827,18806),(828,18806),(829,18806),(830,18806),(831,18806),(832,18806),(833,18806),(834,18806),(835,18806),(836,18806),(837,18806),(838,18806),(839,18806),(840,18806),(841,18806),(842,18806),(843,18806),(844,18806),(845,18806),(846,18806),(847,18806),(848,18806),(849,18806),(850,18806),(851,18806),(852,18806),(853,18806),(854,18806),(855,18806),(856,18806),(857,18806),(858,18806),(859,18806),(860,18806),(861,18806),(862,18806),(863,18806),(864,18806),(865,18806),(866,18806),(867,18806),(868,18806),(869,18806),(870,18806),(871,18806),(872,18806),(873,18806),(874,18806),(875,18806),(876,18806),(877,18806),(878,18806),(879,18806),(880,18806),(881,18806),(882,18806),(883,18806),(884,18806),(885,18806),(886,18806),(887,18806),(888,18806),(889,18806),(890,18806),(891,18806),(892,18806),(893,18806),(894,18806),(895,18806),(896,18806),(897,18806),(898,18806),(899,18806),(900,18806),(901,18806),(902,18806),(903,18806),(904,18806),(905,18806),(906,18806),(907,18806),(908,18806),(909,18806),(910,18806),(911,18806),(912,18806),(913,18806),(914,18806),(915,18806),(916,18806),(917,18806),(918,18806),(919,18806),(920,18806),(921,18806),(922,18806),(923,18806),(924,18806),(925,18806),(926,18806),(927,18806),(928,18806),(929,18806);
/*!40000 ALTER TABLE `synteny_region` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-09-20 18:51:11
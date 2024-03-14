-- MariaDB dump 10.19  Distrib 10.11.2-MariaDB, for osx10.17 (arm64)
--
-- Host: localhost    Database: rnaseq_data
-- ------------------------------------------------------
-- Server version	10.11.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `gene`
--

DROP TABLE IF EXISTS `gene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `gene` (
  `id` int(11) NOT NULL,
  `feature_id` varchar(40) NOT NULL,
  `old_feature_id` varchar(40) DEFAULT NULL,
  `ensembl_id` varchar(25) DEFAULT NULL,
  `name` varchar(20) DEFAULT NULL,
  `type` varchar(30) DEFAULT NULL,
  `chromosome` varchar(10) DEFAULT NULL,
  `start_bp` int(11) DEFAULT NULL,
  `end_bp` int(11) DEFAULT NULL,
  `wikigene_name` varchar(15) DEFAULT NULL,
  `wikigene_description` varchar(200) DEFAULT NULL,
  `human_ortolog_gene_symbol` varchar(50) DEFAULT NULL,
  `human_ortolog_gene_description` varchar(1000) DEFAULT NULL,
  `human_ortolog_gene_pubmed_id` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gene`
--

LOCK TABLES `gene` WRITE;
/*!40000 ALTER TABLE `gene` DISABLE KEYS */;
INSERT INTO `gene` VALUES
(1,'5_8S_rRNA (22 57711376..57711516)','ENSBTAG00000040416','5_8S_rRNA','rRNA','22',57711377,57711516),
(2,'5S_rRNA (1 124790930..124791039)','ENSBTAG00000043802','5S_rRNA','rRNA','1',124790931,124791039),
(3,'5S_rRNA (1 147136867..147136983)','ENSBTAG00000030775','PCBP3','protein_coding','1',147136868,147136983),
(4,'7SK (5 99553714..99554036)','ENSBTAG00000042107','7SK','misc_RNA','5',99553715,99554036),
(5,'ABHD10','ENSBTAG00000004601','ABHD10','protein_coding','1',57156326,57169463),
(6,'ABHD11','ENSBTAG00000010339','ABHD11','protein_coding','25',34041448,34043848);
/*!40000 ALTER TABLE `gene` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-02-23 15:59:25

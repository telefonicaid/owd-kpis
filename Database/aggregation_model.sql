-- MySQL dump 10.13  Distrib 5.1.69, for redhat-linux-gnu (x86_64)
--
-- Host: localhost    Database: kpis_db
-- ------------------------------------------------------
-- Server version	5.1.69-log

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
-- Table structure for table `alias_ip_servidores_aplicaciones`
--

DROP TABLE IF EXISTS `alias_ip_servidores_aplicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `alias_ip_servidores_aplicaciones` (
  `ip` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `alias` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  `country` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  `continent` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  `isp` varchar(20) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calendar`
--

DROP TABLE IF EXISTS `calendar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calendar` (
  `calendar_datetime` datetime NOT NULL,
  PRIMARY KEY (`calendar_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `network_country_codes`
--

DROP TABLE IF EXISTS `network_country_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `network_country_codes` (
  `mcc` char(3) COLLATE utf8_spanish_ci NOT NULL,
  `mnc` char(3) COLLATE utf8_spanish_ci NOT NULL,
  `country` char(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `ob` char(150) COLLATE utf8_spanish_ci DEFAULT NULL,
  `alias` int(11) DEFAULT NULL,
  PRIMARY KEY (`mcc`,`mnc`),
  KEY `fk_network_country_codes_operator1_idx` (`alias`),
  CONSTRAINT `fk_network_country_codes_operator1` FOREIGN KEY (`alias`) REFERENCES `operator` (`idoperator`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_entrantes_agr`
--

DROP TABLE IF EXISTS `notificaciones_entrantes_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_entrantes_agr` (
  `fecha` datetime NOT NULL COMMENT 'viene de notificaciones_entrantes',
  `ip` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `total` int(10) unsigned DEFAULT NULL,
  KEY `fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_entrantes_agr_ld`
--

DROP TABLE IF EXISTS `notificaciones_entrantes_agr_ld`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_entrantes_agr_ld` (
  `fecha` datetime NOT NULL COMMENT 'viene de notificaciones_entrantes',
  `ip` varchar(20) COLLATE utf8_spanish_ci NOT NULL,
  `total` int(10) unsigned DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_entrantes_ncc_agr`
--

DROP TABLE IF EXISTS `notificaciones_entrantes_ncc_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_entrantes_ncc_agr` (
  `fecha` datetime NOT NULL,
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_entrantes_ncc_agr_ld`
--

DROP TABLE IF EXISTS `notificaciones_entrantes_ncc_agr_ld`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_entrantes_ncc_agr_ld` (
  `fecha` datetime NOT NULL,
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(10) unsigned DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_entregadas_agr`
--

DROP TABLE IF EXISTS `notificaciones_entregadas_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_entregadas_agr` (
  `fecha` datetime NOT NULL,
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(10) unsigned DEFAULT NULL COMMENT 'total viene de notificaciones_ws',
  KEY `fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `notificaciones_enviadas_wu`
--

DROP TABLE IF EXISTS `notificaciones_enviadas_wu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones_enviadas_wu` (
  `fecha` datetime NOT NULL COMMENT 'Viene de notificaciones_udp',
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `wakeup` varchar(45) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(11) DEFAULT NULL,
  KEY `fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `operator`
--

DROP TABLE IF EXISTS `operator`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operator` (
  `idoperator` int(11) NOT NULL AUTO_INCREMENT,
  `alias` varchar(150) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`idoperator`)
) ENGINE=InnoDB AUTO_INCREMENT=1225 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `peticiones_registros_agr`
--

DROP TABLE IF EXISTS `peticiones_registros_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `peticiones_registros_agr` (
  `fecha` datetime NOT NULL COMMENT 'viene de peticiones_registros',
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(11) unsigned DEFAULT NULL,
  KEY `fehca` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terminales_agr`
--

DROP TABLE IF EXISTS `terminales_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminales_agr` (
  `fecha` datetime NOT NULL,
  `registrados` int(10) DEFAULT NULL,
  `activos` int(10) DEFAULT NULL,
  `conectados` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terminales_agr_ld`
--

DROP TABLE IF EXISTS `terminales_agr_ld`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminales_agr_ld` (
  `fecha` datetime NOT NULL,
  `activos` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terminales_agr_m`
--

DROP TABLE IF EXISTS `terminales_agr_m`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminales_agr_m` (
  `fecha` datetime NOT NULL,
  `activos` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terminales_agr_w`
--

DROP TABLE IF EXISTS `terminales_agr_w`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminales_agr_w` (
  `fecha` datetime NOT NULL,
  `activos` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `terminales_con_registros_agr`
--

DROP TABLE IF EXISTS `terminales_con_registros_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `terminales_con_registros_agr` (
  `fecha` datetime NOT NULL,
  `mcc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `mnc` varchar(3) COLLATE utf8_spanish_ci DEFAULT NULL,
  `total` int(11) DEFAULT NULL,
  KEY `fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tiempo_notificaciones_agr`
--

DROP TABLE IF EXISTS `tiempo_notificaciones_agr`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tiempo_notificaciones_agr` (
  `fecha` datetime NOT NULL,
  `max` varchar(45) COLLATE utf8_spanish_ci DEFAULT NULL,
  `min` varchar(45) COLLATE utf8_spanish_ci DEFAULT NULL,
  `avg` varchar(45) COLLATE utf8_spanish_ci DEFAULT NULL COMMENT 'La media se puede calcular en periodos mayores ponderando por el nÃºmero de notificaciones que estÃ¡ en notificaciones_entregadas_agr',
  KEY `fecha` (`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-10-08 18:38:43


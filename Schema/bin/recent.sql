-- MySQL dump 10.13  Distrib 5.1.34, for apple-darwin9.5.0 (i386)
--
-- Host: localhost    Database: Plancrow
-- ------------------------------------------------------
-- Server version	5.5.13

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
-- Table structure for table `APP_USER`
--

DROP TABLE IF EXISTS `APP_USER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `APP_USER` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `LOGIN` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `PWD` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `FIRST_NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `SECOND_NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `SALUTATION` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `CREATED_AT` datetime DEFAULT NULL COMMENT 'Auto-filled',
  `PRIMARY_EMAIL` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `IS_ACTIVE` varchar(1) COLLATE utf16_unicode_ci NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users',
  PRIMARY KEY (`id`),
  UNIQUE KEY `login_UNIQUE` (`LOGIN`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `APP_USER`
--

LOCK TABLES `APP_USER` WRITE;
/*!40000 ALTER TABLE `APP_USER` DISABLE KEYS */;
INSERT INTO `APP_USER` VALUES (1,'mkorotkov','123','Maxim','Korotkov',NULL,NULL,'korotkov.maxim@gmail.com','Y'),(2,'ipimenov','123','Ilya','Pimenov',NULL,NULL,'ilya.pimenov@gmail.com','Y'),(3,'tkalapun','123','Taras','Kalapun',NULL,NULL,'t.kalapun@gmail.com','Y');
/*!40000 ALTER TABLE `APP_USER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ASSIGNMENT`
--

DROP TABLE IF EXISTS `ASSIGNMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ASSIGNMENT` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `PROJECT_ID` int(11) DEFAULT NULL,
  `USERLINK_ID` int(11) NOT NULL,
  `TASK_ID` int(11) DEFAULT NULL,
  `TYPE` varchar(2) COLLATE utf16_unicode_ci DEFAULT 'U' COMMENT 'U for user assignment, PM - for Project Manager assignment (defined for projects only)',
  `NOTES` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_PROJECT_idx` (`PROJECT_ID`),
  KEY `FK_TASK_idx` (`TASK_ID`),
  KEY `FK_USERLINK_idx` (`USERLINK_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_ASSIGNMENT_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_TASK` FOREIGN KEY (`TASK_ID`) REFERENCES `TASK` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_USERLINK` FOREIGN KEY (`USERLINK_ID`) REFERENCES `USERLINK` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ASSIGNMENT`
--

LOCK TABLES `ASSIGNMENT` WRITE;
/*!40000 ALTER TABLE `ASSIGNMENT` DISABLE KEYS */;
INSERT INTO `ASSIGNMENT` VALUES (1,NULL,NULL,1,1,1,NULL,'PM',NULL),(2,NULL,NULL,1,1,1,NULL,'U',NULL),(3,NULL,NULL,1,1,1,1,'U',NULL);
/*!40000 ALTER TABLE `ASSIGNMENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `COMPANY`
--

DROP TABLE IF EXISTS `COMPANY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `COMPANY` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `NAME` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `URL_EXT` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Part of the url to be added for website address',
  `CURRENCY_ID` int(11) DEFAULT NULL,
  `PLAN` varchar(16) COLLATE utf16_unicode_ci DEFAULT NULL COMMENT 'Identifier of the obtained plan ',
  `PLAN_EXPIRES` datetime DEFAULT NULL,
  `LIMIT_PROJECTS` int(11) DEFAULT NULL,
  `LIMIT_USERS` int(11) DEFAULT NULL,
  `NOTIFF_DAY` int(11) DEFAULT '5' COMMENT 'Day of week to send timesheet reminders',
  `TIME_UNIT` varchar(1) COLLATE utf16_unicode_ci DEFAULT 'D' COMMENT 'time unit to show spent time. H - hours, D - days',
  `CREATED_AT` datetime DEFAULT NULL COMMENT 'filled automatically',
  PRIMARY KEY (`id`),
  KEY `FK_CURRENCY_idx` (`CURRENCY_ID`),
  CONSTRAINT `FK_COMPANY_CURRENCY` FOREIGN KEY (`CURRENCY_ID`) REFERENCES `CURRENCY` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COMPANY`
--

LOCK TABLES `COMPANY` WRITE;
/*!40000 ALTER TABLE `COMPANY` DISABLE KEYS */;
INSERT INTO `COMPANY` VALUES (1,'ClockHog','clockhog',1,NULL,NULL,NULL,NULL,5,'D',NULL);
/*!40000 ALTER TABLE `COMPANY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CURRENCY`
--

DROP TABLE IF EXISTS `CURRENCY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CURRENCY` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `CODE` varchar(3) COLLATE utf16_unicode_ci DEFAULT NULL,
  `SYMBOL` varchar(1) COLLATE utf16_unicode_ci DEFAULT NULL,
  `NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `currency_code_UNIQUE` (`CODE`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CURRENCY`
--

LOCK TABLES `CURRENCY` WRITE;
/*!40000 ALTER TABLE `CURRENCY` DISABLE KEYS */;
INSERT INTO `CURRENCY` VALUES (1,'EUR','€','Euro'),(2,'USD','$','U.S. Dollar');
/*!40000 ALTER TABLE `CURRENCY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CUSTOMER`
--

DROP TABLE IF EXISTS `CUSTOMER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `CUSTOMER` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) NOT NULL,
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `BILLING_ADDRESS` varchar(256) COLLATE utf16_unicode_ci DEFAULT NULL,
  `CONTACT_PERSON` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_CUSTOMER_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_CUSTOMER_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CUSTOMER`
--

LOCK TABLES `CUSTOMER` WRITE;
/*!40000 ALTER TABLE `CUSTOMER` DISABLE KEYS */;
INSERT INTO `CUSTOMER` VALUES (1,1,NULL,1,'Mega-Customer',NULL,NULL);
/*!40000 ALTER TABLE `CUSTOMER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `INVOICE`
--

DROP TABLE IF EXISTS `INVOICE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `INVOICE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `INVOICE` blob,
  `CREATED_AT` datetime DEFAULT NULL,
  `CUSTOMER_ID` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_CLIENT_idx` (`CUSTOMER_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_INVOICE_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICE_CLIENT` FOREIGN KEY (`CUSTOMER_ID`) REFERENCES `CUSTOMER` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICE_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `INVOICE`
--

LOCK TABLES `INVOICE` WRITE;
/*!40000 ALTER TABLE `INVOICE` DISABLE KEYS */;
/*!40000 ALTER TABLE `INVOICE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `NORM`
--

DROP TABLE IF EXISTS `NORM`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `NORM` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) NOT NULL,
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `PROJECT_ID` int(11) DEFAULT NULL COMMENT 'Total norm if project is null',
  `USERLINK_ID` int(11) DEFAULT NULL COMMENT 'no userlink will mean total for all users',
  `WEEKLY_NORM` bigint(20) DEFAULT NULL COMMENT 'No norm if null',
  `MONTHLY_NORM` bigint(20) DEFAULT NULL COMMENT 'No norm if null',
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_USERLINK_idx` (`USERLINK_ID`),
  KEY `FK_PROJECT_idx` (`PROJECT_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_NORM_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_USERLINK` FOREIGN KEY (`USERLINK_ID`) REFERENCES `USERLINK` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `NORM`
--

LOCK TABLES `NORM` WRITE;
/*!40000 ALTER TABLE `NORM` DISABLE KEYS */;
/*!40000 ALTER TABLE `NORM` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PROJECT`
--

DROP TABLE IF EXISTS `PROJECT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PROJECT` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) NOT NULL,
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  `NOTES` varchar(4096) COLLATE utf16_unicode_ci DEFAULT NULL,
  `BUDGET` decimal(12,2) DEFAULT NULL,
  `ESTIMATE` bigint(20) DEFAULT NULL,
  `COSTS` decimal(12,2) DEFAULT '0.00',
  `SPENT` bigint(20) DEFAULT '0',
  `IS_ACTIVE` varchar(1) COLLATE utf16_unicode_ci DEFAULT 'Y' COMMENT 'For not active projects no active tasks are allowed',
  `CUSTOMER_ID` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_CLIENT_idx` (`CUSTOMER_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_PROJECT_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECT_CLIENT` FOREIGN KEY (`CUSTOMER_ID`) REFERENCES `CUSTOMER` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECT_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PROJECT`
--

LOCK TABLES `PROJECT` WRITE;
/*!40000 ALTER TABLE `PROJECT` DISABLE KEYS */;
INSERT INTO `PROJECT` VALUES (1,1,'2013-05-19 01:10:31',1,'Project 1',NULL,NULL,8640000000,'0.00',0,'Y',1);
/*!40000 ALTER TABLE `PROJECT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PROJECT_PHASE`
--

DROP TABLE IF EXISTS `PROJECT_PHASE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `PROJECT_PHASE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `PROJECT_ID` int(11) NOT NULL,
  `PARENT_ID` int(11) DEFAULT NULL,
  `NAME` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `NOTES` varchar(4096) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_PROJECT_idx` (`PROJECT_ID`),
  KEY `FK_PARENT_idx` (`PARENT_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_PHASE_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_PARENT` FOREIGN KEY (`PARENT_ID`) REFERENCES `PROJECT_PHASE` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PROJECT_PHASE`
--

LOCK TABLES `PROJECT_PHASE` WRITE;
/*!40000 ALTER TABLE `PROJECT_PHASE` DISABLE KEYS */;
INSERT INTO `PROJECT_PHASE` VALUES (1,NULL,NULL,1,1,NULL,'Phase 1',NULL),(2,NULL,NULL,1,1,NULL,'Phase 2',NULL),(3,NULL,NULL,1,1,1,'Phase 1 subphase 1',NULL),(4,NULL,NULL,1,1,1,'Phase 1 subphase 2',NULL);
/*!40000 ALTER TABLE `PROJECT_PHASE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RATE`
--

DROP TABLE IF EXISTS `RATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `RATE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) NOT NULL,
  `AMND_DATE` datetime DEFAULT NULL,
  `AMND_USER` int(11) DEFAULT NULL,
  `USERLINK_ID` int(11) DEFAULT NULL COMMENT 'If userlink_id and project_id are null - company rate; if userlink_id is null - project rate; if project_id is null - user rate. If project rate is defined - userlink_id cannot be null to avoid ambiguity',
  `PROJECT_ID` int(11) DEFAULT NULL,
  `RATE` decimal(12,2) DEFAULT NULL,
  `RATE_TYPE` varchar(1) COLLATE utf16_unicode_ci DEFAULT 'D' COMMENT 'D - daily; W - weekly; H - hourly; M - monthly',
  `RATE_DATE_FROM` datetime DEFAULT NULL COMMENT 'null for first created rate',
  `RATE_DATE_TO` datetime DEFAULT NULL COMMENT 'null for active rate of the type',
  PRIMARY KEY (`id`),
  KEY `FK_USERLINK_idx` (`USERLINK_ID`),
  KEY `FK_PROJECT_idx` (`PROJECT_ID`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `INDEX_PERIOD` (`COMPANY_ID`,`USERLINK_ID`,`PROJECT_ID`,`RATE_DATE_FROM`,`RATE_DATE_TO`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_RATE_USERLINK` FOREIGN KEY (`USERLINK_ID`) REFERENCES `USERLINK` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RATE`
--

LOCK TABLES `RATE` WRITE;
/*!40000 ALTER TABLE `RATE` DISABLE KEYS */;
/*!40000 ALTER TABLE `RATE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TASK`
--

DROP TABLE IF EXISTS `TASK`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TASK` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `PROJECT_PHASE_ID` int(11) NOT NULL,
  `PROJECT_ID` int(11) DEFAULT NULL COMMENT 'Non-normalized link to simplify totals calculation; filled automatically',
  `NAME` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `NOTES` varchar(4096) COLLATE utf16_unicode_ci DEFAULT NULL,
  `ESTIMATE` bigint(20) DEFAULT NULL,
  `POSTED` bigint(20) DEFAULT '0',
  `STATUS` varchar(1) COLLATE utf16_unicode_ci DEFAULT 'N' COMMENT 'A - active; C - completed; N - not started',
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_PROJECT_idx` (`PROJECT_ID`),
  KEY `FK_PHASE_idx` (`PROJECT_PHASE_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_TASK_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_PHASE` FOREIGN KEY (`PROJECT_PHASE_ID`) REFERENCES `PROJECT_PHASE` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TASK`
--

LOCK TABLES `TASK` WRITE;
/*!40000 ALTER TABLE `TASK` DISABLE KEYS */;
INSERT INTO `TASK` VALUES (1,NULL,NULL,1,3,NULL,'Task A',NULL,172800000,0,'A'),(2,NULL,NULL,1,3,NULL,'Task B',NULL,432000000,0,'A'),(3,NULL,NULL,1,4,NULL,'Task C',NULL,86400000,0,'A'),(4,NULL,NULL,1,2,NULL,'Task D',NULL,864000000,0,'A');
/*!40000 ALTER TABLE `TASK` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TEMPLATE`
--

DROP TABLE IF EXISTS `TEMPLATE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TEMPLATE` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `CUSTOMER_ID` int(11) NOT NULL,
  `TEMPLATE` blob,
  `TEMPLATE_NAME` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_CLIENT_idx` (`CUSTOMER_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_TEMPLATE_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATE_CLIENT` FOREIGN KEY (`CUSTOMER_ID`) REFERENCES `CUSTOMER` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATE_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TEMPLATE`
--

LOCK TABLES `TEMPLATE` WRITE;
/*!40000 ALTER TABLE `TEMPLATE` DISABLE KEYS */;
/*!40000 ALTER TABLE `TEMPLATE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `TIMING`
--

DROP TABLE IF EXISTS `TIMING`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `TIMING` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) DEFAULT NULL COMMENT 'auto-filled',
  `AMND_DATE` datetime DEFAULT NULL COMMENT 'auto-filled',
  `AMND_USER` int(11) DEFAULT NULL,
  `TASK_ID` int(11) NOT NULL,
  `VALUE` bigint(20) NOT NULL,
  `TIMING_DATE` datetime NOT NULL,
  `USERLINK_ID` int(11) NOT NULL,
  `RATE_ID` int(11) DEFAULT NULL COMMENT 'Can be of non-identified rate (only used when rates are not setup!!!)',
  `PROJECT_ID` int(11) DEFAULT NULL COMMENT 'not-normalized for better search, filled automatically',
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_USERLINK_idx` (`USERLINK_ID`),
  KEY `FK_TASK_idx` (`TASK_ID`),
  KEY `FK_RATE_idx` (`RATE_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  KEY `FK_TIMING_PROJECT_idx` (`PROJECT_ID`),
  KEY `FT_TIMING_PERIOD` (`PROJECT_ID`,`USERLINK_ID`,`TIMING_DATE`),
  CONSTRAINT `FK_TIMING_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_USERLINK` FOREIGN KEY (`USERLINK_ID`) REFERENCES `USERLINK` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_TASK` FOREIGN KEY (`TASK_ID`) REFERENCES `TASK` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_RATE` FOREIGN KEY (`RATE_ID`) REFERENCES `RATE` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_PROJECT` FOREIGN KEY (`PROJECT_ID`) REFERENCES `PROJECT` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `TIMING`
--

LOCK TABLES `TIMING` WRITE;
/*!40000 ALTER TABLE `TIMING` DISABLE KEYS */;
INSERT INTO `TIMING` VALUES (1,NULL,NULL,1,1,3600000,'2013-05-19 01:10:31',1,NULL,NULL),(2,NULL,NULL,1,2,3600000,'2013-05-19 01:10:31',1,NULL,NULL),(3,NULL,NULL,2,1,7200000,'2013-05-19 01:10:31',2,NULL,NULL);
/*!40000 ALTER TABLE `TIMING` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `USERLINK`
--

DROP TABLE IF EXISTS `USERLINK`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `USERLINK` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `COMPANY_ID` int(11) NOT NULL,
  `USER_ID` int(11) NOT NULL,
  `AMND_DATE` datetime DEFAULT NULL,
  `AMND_USER` int(11) DEFAULT NULL,
  `EMAIL` varchar(45) COLLATE utf16_unicode_ci NOT NULL,
  `ROLE` varchar(4) COLLATE utf16_unicode_ci NOT NULL DEFAULT 'EXEC' COMMENT 'ADM = admin, PM = PM; EXEC = Operator;',
  `IS_ACTIVE` varchar(1) COLLATE utf16_unicode_ci NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users (required to keep history timings)',
  `JOB_TITLE` varchar(45) COLLATE utf16_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_COMPANY_idx` (`COMPANY_ID`),
  KEY `FK_USER_idx` (`USER_ID`),
  KEY `FK_AMND_USER_idx` (`AMND_USER`),
  CONSTRAINT `FK_USERLINK_USER` FOREIGN KEY (`USER_ID`) REFERENCES `APP_USER` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `FK_USERLINK_COMPANY` FOREIGN KEY (`COMPANY_ID`) REFERENCES `COMPANY` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_USERLINK_AMND_USER` FOREIGN KEY (`AMND_USER`) REFERENCES `APP_USER` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf16 COLLATE=utf16_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `USERLINK`
--

LOCK TABLES `USERLINK` WRITE;
/*!40000 ALTER TABLE `USERLINK` DISABLE KEYS */;
INSERT INTO `USERLINK` VALUES (1,1,1,NULL,1,'korotkov.maxim@gmail.com','PM','Y',NULL),(2,1,2,NULL,1,'ilya.pimenov@gmail.com','ADM','Y',NULL),(3,1,3,NULL,1,'t.kalapun@gmail.com','EXEC','Y',NULL);
/*!40000 ALTER TABLE `USERLINK` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2013-05-18 23:11:36
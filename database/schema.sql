CREATE DATABASE  IF NOT EXISTS `recruitmentdb` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `recruitmentdb`;
-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: recruitmentdb
-- ------------------------------------------------------
-- Server version	8.4.7

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_accounts`
--

DROP TABLE IF EXISTS `admin_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_accounts` (
  `AdminID` int NOT NULL AUTO_INCREMENT,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`AdminID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `analyst_accounts`
--

DROP TABLE IF EXISTS `analyst_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `analyst_accounts` (
  `AnalystID` int NOT NULL AUTO_INCREMENT,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`AnalystID`),
  UNIQUE KEY `Email` (`Email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `applications`
--

DROP TABLE IF EXISTS `applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applications` (
  `ApplicationID` int NOT NULL AUTO_INCREMENT,
  `CandidateID` int NOT NULL,
  `PositionID` int NOT NULL,
  `ApplicationDate` date NOT NULL DEFAULT (curdate()),
  `CoverLetter` text COLLATE utf8mb4_unicode_ci,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Applied',
  `ScreeningNote` text COLLATE utf8mb4_unicode_ci,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `DeletedAt` timestamp NULL DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ApplicationID`),
  KEY `PositionID` (`PositionID`),
  KEY `idx_app_candidate_pos` (`CandidateID`,`PositionID`),
  KEY `idx_app_status` (`Status`),
  KEY `idx_app_date` (`ApplicationDate`),
  CONSTRAINT `applications_ibfk_1` FOREIGN KEY (`CandidateID`) REFERENCES `candidates` (`CandidateID`) ON DELETE RESTRICT,
  CONSTRAINT `applications_ibfk_2` FOREIGN KEY (`PositionID`) REFERENCES `jobpositions` (`PositionID`) ON DELETE RESTRICT,
  CONSTRAINT `chk_app_status` CHECK ((`Status` in (_utf8mb4'Applied',_utf8mb4'Screening',_utf8mb4'Interviewing',_utf8mb4'Offered',_utf8mb4'Rejected',_utf8mb4'Accepted',_utf8mb4'Withdrawn')))
) ENGINE=InnoDB AUTO_INCREMENT=6241 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Application_AfterUpdate` AFTER UPDATE ON `applications` FOR EACH ROW BEGIN
    IF NEW.Status != OLD.Status THEN
        INSERT INTO ApplicationStatusLog(ApplicationID, OldStatus, NewStatus, ChangedBy)
        VALUES (NEW.ApplicationID, OLD.Status, NEW.Status,
                IFNULL(@app_user, USER()));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_AppStatus_Notification` AFTER UPDATE ON `applications` FOR EACH ROW BEGIN
    DECLARE v_PositionName VARCHAR(150);
    DECLARE v_EmployerName VARCHAR(150);
    IF NEW.Status != OLD.Status THEN
        SELECT p.PositionName, e.EmployerName INTO v_PositionName, v_EmployerName
        FROM JobPositions p
        JOIN Employers e ON p.EmployerID = e.EmployerID
        WHERE p.PositionID = NEW.PositionID;
        INSERT INTO CandidateNotifications (CandidateID, Message)
        VALUES (NEW.CandidateID,
                CONCAT('Đơn ứng tuyển #', NEW.ApplicationID,
                       ' cho vị trí ', v_PositionName,
                       ' tại ', v_EmployerName,
                       ' đã chuyển từ ', OLD.Status, ' sang ', NEW.Status, '.'));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `applications_archive`
--

DROP TABLE IF EXISTS `applications_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applications_archive` (
  `ArchiveID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int DEFAULT NULL,
  `CandidateID` int DEFAULT NULL,
  `PositionID` int DEFAULT NULL,
  `ApplicationDate` date DEFAULT NULL,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ArchivedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ArchiveID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `applicationstatuslog`
--

DROP TABLE IF EXISTS `applicationstatuslog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `applicationstatuslog` (
  `LogID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int NOT NULL,
  `OldStatus` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NewStatus` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ChangedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ChangedBy` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  `Remark` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`LogID`),
  KEY `ApplicationID` (`ApplicationID`),
  CONSTRAINT `applicationstatuslog_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3852 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `candidateaccounts`
--

DROP TABLE IF EXISTS `candidateaccounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidateaccounts` (
  `AccountID` int NOT NULL AUTO_INCREMENT,
  `CandidateID` int NOT NULL,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT '1',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`AccountID`),
  UNIQUE KEY `CandidateID` (`CandidateID`),
  UNIQUE KEY `Email` (`Email`),
  CONSTRAINT `candidateaccounts_ibfk_1` FOREIGN KEY (`CandidateID`) REFERENCES `candidates` (`CandidateID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `candidatenotifications`
--

DROP TABLE IF EXISTS `candidatenotifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidatenotifications` (
  `NotifID` int NOT NULL AUTO_INCREMENT,
  `CandidateID` int NOT NULL,
  `Message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `IsRead` tinyint(1) DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`NotifID`),
  KEY `CandidateID` (`CandidateID`),
  CONSTRAINT `candidatenotifications_ibfk_1` FOREIGN KEY (`CandidateID`) REFERENCES `candidates` (`CandidateID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3852 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `candidates`
--

DROP TABLE IF EXISTS `candidates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidates` (
  `CandidateID` int NOT NULL AUTO_INCREMENT,
  `CandidateName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Gender` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `DateOfBirth` date DEFAULT NULL,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PhoneNumber` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Address` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `EducationLevel` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `GPA` decimal(4,2) DEFAULT NULL,
  `YearsOfExperience` int NOT NULL DEFAULT '0',
  `ResumeURL` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `DeletedAt` timestamp NULL DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`CandidateID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `idx_candidate_email` (`Email`),
  CONSTRAINT `chk_cand_edu` CHECK ((`EducationLevel` in (_utf8mb4'High School',_utf8mb4'Associate',_utf8mb4'Bachelor',_utf8mb4'Master',_utf8mb4'PhD'))),
  CONSTRAINT `chk_cand_gender` CHECK ((`Gender` in (_utf8mb4'Male',_utf8mb4'Female',_utf8mb4'Other'))),
  CONSTRAINT `chk_exp` CHECK ((`YearsOfExperience` >= 0)),
  CONSTRAINT `chk_gpa` CHECK (((`GPA` is null) or ((`GPA` >= 0.00) and (`GPA` <= 4.00))))
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Candidates_Email_BI` BEFORE INSERT ON `candidates` FOR EACH ROW BEGIN
    SET NEW.Email = LOWER(TRIM(NEW.Email));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Candidates_Email_BU` BEFORE UPDATE ON `candidates` FOR EACH ROW BEGIN
    SET NEW.Email = LOWER(TRIM(NEW.Email));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Candidate_SoftDelete` AFTER UPDATE ON `candidates` FOR EACH ROW BEGIN
    IF NEW.IsDeleted = TRUE AND OLD.IsDeleted = FALSE THEN
        UPDATE Applications
        SET    IsDeleted = TRUE, DeletedAt = NOW()
        WHERE  CandidateID = NEW.CandidateID
          AND  IsDeleted   = FALSE;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `candidateskills`
--

DROP TABLE IF EXISTS `candidateskills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `candidateskills` (
  `CandidateID` int NOT NULL,
  `SkillID` int NOT NULL,
  `ProficiencyLevel` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Intermediate',
  `YearsUsed` decimal(4,1) DEFAULT NULL,
  PRIMARY KEY (`CandidateID`,`SkillID`),
  KEY `idx_candidate_skills_skill` (`SkillID`),
  CONSTRAINT `candidateskills_ibfk_1` FOREIGN KEY (`CandidateID`) REFERENCES `candidates` (`CandidateID`) ON DELETE CASCADE,
  CONSTRAINT `candidateskills_ibfk_2` FOREIGN KEY (`SkillID`) REFERENCES `skills` (`SkillID`) ON DELETE CASCADE,
  CONSTRAINT `chk_cand_skill_level` CHECK ((`ProficiencyLevel` in (_utf8mb4'Beginner',_utf8mb4'Intermediate',_utf8mb4'Advanced'))),
  CONSTRAINT `chk_years_used` CHECK (((`YearsUsed` is null) or (`YearsUsed` >= 0)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `DepartmentID` int NOT NULL AUTO_INCREMENT,
  `EmployerID` int NOT NULL,
  `DepartmentName` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ManagerName` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`DepartmentID`),
  KEY `idx_department_employer` (`EmployerID`),
  CONSTRAINT `departments_ibfk_1` FOREIGN KEY (`EmployerID`) REFERENCES `employers` (`EmployerID`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employers`
--

DROP TABLE IF EXISTS `employers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employers` (
  `EmployerID` int NOT NULL AUTO_INCREMENT,
  `EmployerName` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `IndustryID` int DEFAULT NULL,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PhoneNumber` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Address` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `CompanySize` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Medium',
  `LogoURL` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `DeletedAt` timestamp NULL DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `CompanyDescription` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`EmployerID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `IndustryID` (`IndustryID`),
  KEY `idx_employer_email` (`Email`),
  CONSTRAINT `employers_ibfk_1` FOREIGN KEY (`IndustryID`) REFERENCES `industries` (`IndustryID`) ON DELETE SET NULL,
  CONSTRAINT `chk_company_size` CHECK ((`CompanySize` in (_utf8mb4'Startup',_utf8mb4'Small',_utf8mb4'Medium',_utf8mb4'Large',_utf8mb4'Enterprise')))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Employers_Email_BI` BEFORE INSERT ON `employers` FOR EACH ROW BEGIN
    SET NEW.Email = LOWER(TRIM(NEW.Email));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Employers_Email_BU` BEFORE UPDATE ON `employers` FOR EACH ROW BEGIN
    SET NEW.Email = LOWER(TRIM(NEW.Email));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Employer_SoftDelete` AFTER UPDATE ON `employers` FOR EACH ROW BEGIN
    IF NEW.IsDeleted = TRUE AND OLD.IsDeleted = FALSE THEN
        UPDATE Departments  SET IsDeleted = TRUE WHERE EmployerID = NEW.EmployerID AND IsDeleted = FALSE;
        UPDATE Interviewers SET IsDeleted = TRUE WHERE EmployerID = NEW.EmployerID AND IsDeleted = FALSE;
        
        UPDATE Applications a
        JOIN JobPositions jp ON a.PositionID = jp.PositionID
        SET a.IsDeleted = TRUE, a.DeletedAt = NOW()
        WHERE jp.EmployerID = NEW.EmployerID AND a.IsDeleted = FALSE;

        UPDATE JobPositions SET IsDeleted = TRUE, DeletedAt = NOW(), Status = 'Closed'
        WHERE EmployerID = NEW.EmployerID AND IsDeleted = FALSE;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `hr_accounts`
--

DROP TABLE IF EXISTS `hr_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hr_accounts` (
  `HR_ID` int NOT NULL AUTO_INCREMENT,
  `EmployerID` int NOT NULL,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`HR_ID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `EmployerID` (`EmployerID`),
  CONSTRAINT `hr_accounts_ibfk_1` FOREIGN KEY (`EmployerID`) REFERENCES `employers` (`EmployerID`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `industries` (
  `IndustryID` int NOT NULL AUTO_INCREMENT,
  `IndustryName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Description` text COLLATE utf8mb4_unicode_ci,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`IndustryID`),
  UNIQUE KEY `IndustryName` (`IndustryName`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interviewer_accounts`
--

DROP TABLE IF EXISTS `interviewer_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviewer_accounts` (
  `InterviewerID` int NOT NULL,
  `PasswordHash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsActive` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`InterviewerID`),
  CONSTRAINT `interviewer_accounts_ibfk_1` FOREIGN KEY (`InterviewerID`) REFERENCES `interviewers` (`InterviewerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interviewernotifications`
--

DROP TABLE IF EXISTS `interviewernotifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviewernotifications` (
  `NotifID` int NOT NULL AUTO_INCREMENT,
  `InterviewerID` int NOT NULL,
  `Message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `IsRead` tinyint(1) DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `RelatedID` int DEFAULT NULL,
  PRIMARY KEY (`NotifID`),
  KEY `InterviewerID` (`InterviewerID`),
  CONSTRAINT `interviewernotifications_ibfk_1` FOREIGN KEY (`InterviewerID`) REFERENCES `interviewers` (`InterviewerID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12830 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interviewers`
--

DROP TABLE IF EXISTS `interviewers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviewers` (
  `InterviewerID` int NOT NULL AUTO_INCREMENT,
  `EmployerID` int NOT NULL,
  `FullName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Email` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `JobTitle` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`InterviewerID`),
  UNIQUE KEY `Email` (`Email`),
  KEY `EmployerID` (`EmployerID`),
  CONSTRAINT `interviewers_ibfk_1` FOREIGN KEY (`EmployerID`) REFERENCES `employers` (`EmployerID`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interviewlog`
--

DROP TABLE IF EXISTS `interviewlog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviewlog` (
  `LogID` int NOT NULL AUTO_INCREMENT,
  `InterviewID` int NOT NULL,
  `OldScore` decimal(5,2) DEFAULT NULL,
  `NewScore` decimal(5,2) DEFAULT NULL,
  `OldResult` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `NewResult` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ChangedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `ChangedBy` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'SYSTEM',
  PRIMARY KEY (`LogID`),
  KEY `InterviewID` (`InterviewID`),
  CONSTRAINT `interviewlog_ibfk_1` FOREIGN KEY (`InterviewID`) REFERENCES `interviews` (`InterviewID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1961 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `interviewpanel`
--

DROP TABLE IF EXISTS `interviewpanel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviewpanel` (
  `InterviewID` int NOT NULL,
  `InterviewerID` int NOT NULL,
  `Role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Panelist',
  `IsConfirmed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`InterviewID`,`InterviewerID`),
  KEY `InterviewerID` (`InterviewerID`),
  CONSTRAINT `interviewpanel_ibfk_1` FOREIGN KEY (`InterviewID`) REFERENCES `interviews` (`InterviewID`) ON DELETE CASCADE,
  CONSTRAINT `interviewpanel_ibfk_2` FOREIGN KEY (`InterviewerID`) REFERENCES `interviewers` (`InterviewerID`) ON DELETE CASCADE,
  CONSTRAINT `chk_panel_role` CHECK ((`Role` in (_utf8mb4'Lead',_utf8mb4'Panelist',_utf8mb4'Observer')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Interviewer_After_Insert` AFTER INSERT ON `interviewpanel` FOR EACH ROW BEGIN
    DECLARE v_CandidateName VARCHAR(100);
    DECLARE v_PositionName VARCHAR(150);
    DECLARE v_InterviewDate DATETIME;

    SELECT c.CandidateName, p.PositionName, i.InterviewDate
    INTO v_CandidateName, v_PositionName, v_InterviewDate
    FROM Interviews i
    JOIN Applications a ON i.ApplicationID = a.ApplicationID
    JOIN Candidates c ON a.CandidateID = c.CandidateID
    JOIN JobPositions p ON a.PositionID = p.PositionID
    WHERE i.InterviewID = NEW.InterviewID;

    INSERT INTO InterviewerNotifications (InterviewerID, Message, RelatedID)
    VALUES (NEW.InterviewerID, 
            CONCAT('Phỏng vấn ', v_CandidateName, 
                   ' cho vị trí ', v_PositionName, 
                   ' vào lúc ', DATE_FORMAT(v_InterviewDate, '%H:%i %d/%m/%Y')),
            NEW.InterviewID);
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `interviews`
--

DROP TABLE IF EXISTS `interviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `interviews` (
  `InterviewID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int NOT NULL,
  `InterviewerID` int DEFAULT NULL,
  `InterviewDate` datetime NOT NULL,
  `Duration` int DEFAULT '60',
  `RoundNumber` int NOT NULL DEFAULT '1',
  `InterviewType` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'In-person',
  `Location` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Score` decimal(5,2) DEFAULT NULL,
  `MaxScore` decimal(5,2) NOT NULL DEFAULT '100.00',
  `Result` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `Note` text COLLATE utf8mb4_unicode_ci,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`InterviewID`),
  KEY `InterviewerID` (`InterviewerID`),
  KEY `idx_interview_app_round` (`ApplicationID`,`RoundNumber`),
  KEY `idx_interview_date` (`InterviewDate`),
  CONSTRAINT `interviews_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`) ON DELETE RESTRICT,
  CONSTRAINT `interviews_ibfk_2` FOREIGN KEY (`InterviewerID`) REFERENCES `interviewers` (`InterviewerID`) ON DELETE SET NULL,
  CONSTRAINT `chk_duration` CHECK ((`Duration` > 0)),
  CONSTRAINT `chk_interview_result` CHECK ((`Result` in (_utf8mb4'Pass',_utf8mb4'Fail',_utf8mb4'Pending'))),
  CONSTRAINT `chk_iv_type` CHECK ((`InterviewType` in (_utf8mb4'Phone',_utf8mb4'Online',_utf8mb4'In-person',_utf8mb4'Technical',_utf8mb4'HR'))),
  CONSTRAINT `chk_max_score` CHECK ((`MaxScore` > 0)),
  CONSTRAINT `chk_round_num` CHECK ((`RoundNumber` >= 1)),
  CONSTRAINT `chk_score_range` CHECK (((`Score` is null) or ((`Score` >= 0) and (`Score` <= `MaxScore`))))
) ENGINE=InnoDB AUTO_INCREMENT=984 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_Interview_AfterUpdate` AFTER UPDATE ON `interviews` FOR EACH ROW BEGIN
    -- Chỉ ghi log, không tự động cập nhật Application status
    IF NOT (NEW.Score <=> OLD.Score) OR NOT (NEW.Result <=> OLD.Result) THEN
        INSERT INTO InterviewLog(InterviewID, OldScore, NewScore, OldResult, NewResult, ChangedBy)
        VALUES (NEW.InterviewID, OLD.Score, NEW.Score, OLD.Result, NEW.Result, IFNULL(@app_user, USER()));
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `joboffers`
--

DROP TABLE IF EXISTS `joboffers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `joboffers` (
  `OfferID` int NOT NULL AUTO_INCREMENT,
  `ApplicationID` int NOT NULL,
  `BasicSalary` decimal(15,2) NOT NULL,
  `OfferDate` date NOT NULL,
  `ValidUntil` date NOT NULL,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Pending',
  `Note` text COLLATE utf8mb4_unicode_ci,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`OfferID`),
  KEY `ApplicationID` (`ApplicationID`),
  CONSTRAINT `joboffers_ibfk_1` FOREIGN KEY (`ApplicationID`) REFERENCES `applications` (`ApplicationID`) ON DELETE RESTRICT,
  CONSTRAINT `chk_offer_status` CHECK ((`Status` in (_utf8mb4'Pending',_utf8mb4'Accepted',_utf8mb4'Declined',_utf8mb4'Revoked')))
) ENGINE=InnoDB AUTO_INCREMENT=197 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobpositions`
--

DROP TABLE IF EXISTS `jobpositions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobpositions` (
  `PositionID` int NOT NULL AUTO_INCREMENT,
  `EmployerID` int NOT NULL,
  `DepartmentID` int DEFAULT NULL,
  `PositionName` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `JobDescription` text COLLATE utf8mb4_unicode_ci,
  `JobType` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Full-time',
  `SalaryMin` decimal(15,2) DEFAULT NULL,
  `SalaryMax` decimal(15,2) DEFAULT NULL,
  `ExperienceYears` int DEFAULT '0',
  `EducationLevel` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Any',
  `Location` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Openings` int NOT NULL DEFAULT '1',
  `MaxRounds` int NOT NULL DEFAULT '3',
  `Deadline` date DEFAULT NULL,
  `Status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Open',
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `DeletedAt` timestamp NULL DEFAULT NULL,
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UpdatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`PositionID`),
  KEY `DepartmentID` (`DepartmentID`),
  KEY `idx_job_employer` (`EmployerID`),
  KEY `idx_job_status` (`Status`),
  CONSTRAINT `jobpositions_ibfk_1` FOREIGN KEY (`EmployerID`) REFERENCES `employers` (`EmployerID`) ON DELETE RESTRICT,
  CONSTRAINT `jobpositions_ibfk_2` FOREIGN KEY (`DepartmentID`) REFERENCES `departments` (`DepartmentID`) ON DELETE SET NULL,
  CONSTRAINT `chk_job_edu` CHECK ((`EducationLevel` in (_utf8mb4'High School',_utf8mb4'Associate',_utf8mb4'Bachelor',_utf8mb4'Master',_utf8mb4'PhD',_utf8mb4'Any'))),
  CONSTRAINT `chk_job_status` CHECK ((`Status` in (_utf8mb4'Draft',_utf8mb4'Open',_utf8mb4'Closed',_utf8mb4'On Hold'))),
  CONSTRAINT `chk_job_type` CHECK ((`JobType` in (_utf8mb4'Full-time',_utf8mb4'Part-time',_utf8mb4'Contract',_utf8mb4'Internship',_utf8mb4'Remote'))),
  CONSTRAINT `chk_max_rounds` CHECK ((`MaxRounds` >= 1)),
  CONSTRAINT `chk_openings` CHECK ((`Openings` >= 1)),
  CONSTRAINT `chk_salary` CHECK (((`SalaryMin` is null) or (`SalaryMax` is null) or (`SalaryMin` <= `SalaryMax`)))
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobrequirements`
--

DROP TABLE IF EXISTS `jobrequirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobrequirements` (
  `PositionID` int NOT NULL,
  `SkillID` int NOT NULL,
  `RequiredLevel` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Intermediate',
  `IsMandatory` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`PositionID`,`SkillID`),
  KEY `idx_job_requirements_skill` (`SkillID`),
  CONSTRAINT `jobrequirements_ibfk_1` FOREIGN KEY (`PositionID`) REFERENCES `jobpositions` (`PositionID`) ON DELETE CASCADE,
  CONSTRAINT `jobrequirements_ibfk_2` FOREIGN KEY (`SkillID`) REFERENCES `skills` (`SkillID`) ON DELETE CASCADE,
  CONSTRAINT `chk_req_level` CHECK ((`RequiredLevel` in (_utf8mb4'Beginner',_utf8mb4'Intermediate',_utf8mb4'Advanced')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `savedjobs`
--

DROP TABLE IF EXISTS `savedjobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `savedjobs` (
  `SavedID` int NOT NULL AUTO_INCREMENT,
  `CandidateID` int NOT NULL,
  `PositionID` int NOT NULL,
  `SavedDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`SavedID`),
  UNIQUE KEY `unique_saved` (`CandidateID`,`PositionID`),
  KEY `PositionID` (`PositionID`),
  CONSTRAINT `savedjobs_ibfk_1` FOREIGN KEY (`CandidateID`) REFERENCES `candidates` (`CandidateID`) ON DELETE CASCADE,
  CONSTRAINT `savedjobs_ibfk_2` FOREIGN KEY (`PositionID`) REFERENCES `jobpositions` (`PositionID`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=259 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `skills`
--

DROP TABLE IF EXISTS `skills`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `skills` (
  `SkillID` int NOT NULL AUTO_INCREMENT,
  `SkillName` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Category` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `IsDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `CreatedAt` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`SkillID`),
  UNIQUE KEY `SkillName` (`SkillName`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `view_applicationsummary`
--

DROP TABLE IF EXISTS `view_applicationsummary`;
/*!50001 DROP VIEW IF EXISTS `view_applicationsummary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_applicationsummary` AS SELECT 
 1 AS `PositionID`,
 1 AS `PositionName`,
 1 AS `EmployerName`,
 1 AS `TotalApplications`,
 1 AS `Applied`,
 1 AS `Interviewing`,
 1 AS `Offered`,
 1 AS `Accepted`,
 1 AS `Rejected`,
 1 AS `AcceptanceRate`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_candidateanalytics`
--

DROP TABLE IF EXISTS `view_candidateanalytics`;
/*!50001 DROP VIEW IF EXISTS `view_candidateanalytics`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_candidateanalytics` AS SELECT 
 1 AS `CandidateID`,
 1 AS `Gender`,
 1 AS `Age`,
 1 AS `EducationLevel`,
 1 AS `GPA`,
 1 AS `YearsOfExperience`,
 1 AS `JobType`,
 1 AS `RoundNumber`,
 1 AS `InterviewType`,
 1 AS `Score`,
 1 AS `NormalizedScore`,
 1 AS `Result`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_employerrecruitmentstats`
--

DROP TABLE IF EXISTS `view_employerrecruitmentstats`;
/*!50001 DROP VIEW IF EXISTS `view_employerrecruitmentstats`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_employerrecruitmentstats` AS SELECT 
 1 AS `EmployerID`,
 1 AS `EmployerName`,
 1 AS `TotalPositions`,
 1 AS `TotalApplications`,
 1 AS `TotalInterviews`,
 1 AS `Hires`,
 1 AS `AvgInterviewScore`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_interviewerworkload`
--

DROP TABLE IF EXISTS `view_interviewerworkload`;
/*!50001 DROP VIEW IF EXISTS `view_interviewerworkload`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_interviewerworkload` AS SELECT 
 1 AS `InterviewerID`,
 1 AS `FullName`,
 1 AS `EmployerName`,
 1 AS `TotalInterviews`,
 1 AS `UniqueCandidates`,
 1 AS `AvgGivenScore`,
 1 AS `Passes`,
 1 AS `Fails`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_interviewresults`
--

DROP TABLE IF EXISTS `view_interviewresults`;
/*!50001 DROP VIEW IF EXISTS `view_interviewresults`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_interviewresults` AS SELECT 
 1 AS `CandidateID`,
 1 AS `CandidateName`,
 1 AS `CandidateEmail`,
 1 AS `EmployerName`,
 1 AS `PositionName`,
 1 AS `RoundNumber`,
 1 AS `InterviewType`,
 1 AS `InterviewDate`,
 1 AS `InterviewerName`,
 1 AS `Score`,
 1 AS `MaxScore`,
 1 AS `ScorePct`,
 1 AS `Result`,
 1 AS `Note`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_monthlyrecruitmentfunnel`
--

DROP TABLE IF EXISTS `view_monthlyrecruitmentfunnel`;
/*!50001 DROP VIEW IF EXISTS `view_monthlyrecruitmentfunnel`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_monthlyrecruitmentfunnel` AS SELECT 
 1 AS `Month`,
 1 AS `EmployerID`,
 1 AS `EmployerName`,
 1 AS `Applications`,
 1 AS `MovedForward`,
 1 AS `Hired`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_openpositions`
--

DROP TABLE IF EXISTS `view_openpositions`;
/*!50001 DROP VIEW IF EXISTS `view_openpositions`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_openpositions` AS SELECT 
 1 AS `PositionID`,
 1 AS `PositionName`,
 1 AS `EmployerName`,
 1 AS `IndustryName`,
 1 AS `JobType`,
 1 AS `Location`,
 1 AS `SalaryMin`,
 1 AS `SalaryMax`,
 1 AS `ExperienceYears`,
 1 AS `EducationLevel`,
 1 AS `Deadline`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_shortlistedcandidates`
--

DROP TABLE IF EXISTS `view_shortlistedcandidates`;
/*!50001 DROP VIEW IF EXISTS `view_shortlistedcandidates`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_shortlistedcandidates` AS SELECT 
 1 AS `CandidateID`,
 1 AS `CandidateName`,
 1 AS `Email`,
 1 AS `PhoneNumber`,
 1 AS `PositionName`,
 1 AS `EmployerName`,
 1 AS `ApplicationDate`,
 1 AS `Status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_stageconversionrates`
--

DROP TABLE IF EXISTS `view_stageconversionrates`;
/*!50001 DROP VIEW IF EXISTS `view_stageconversionrates`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_stageconversionrates` AS SELECT 
 1 AS `PositionID`,
 1 AS `PositionName`,
 1 AS `EmployerName`,
 1 AS `TotalApplied`,
 1 AS `Screened`,
 1 AS `Interviewed`,
 1 AS `OfferedCount`,
 1 AS `Hired`,
 1 AS `ScreeningRate`,
 1 AS `InterviewRate`,
 1 AS `OfferRate`,
 1 AS `AcceptanceRate`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `view_topcandidates`
--

DROP TABLE IF EXISTS `view_topcandidates`;
/*!50001 DROP VIEW IF EXISTS `view_topcandidates`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `view_topcandidates` AS SELECT 
 1 AS `PositionName`,
 1 AS `EmployerName`,
 1 AS `CandidateName`,
 1 AS `AvgScore`,
 1 AS `TotalRounds`,
 1 AS `RankNum`,
 1 AS `ApplicationStatus`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `view_applicationsummary`
--

/*!50001 DROP VIEW IF EXISTS `view_applicationsummary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_applicationsummary` AS select `p`.`PositionID` AS `PositionID`,`p`.`PositionName` AS `PositionName`,`e`.`EmployerName` AS `EmployerName`,count(`a`.`ApplicationID`) AS `TotalApplications`,sum((`a`.`Status` = 'Applied')) AS `Applied`,sum((`a`.`Status` = 'Interviewing')) AS `Interviewing`,sum((`a`.`Status` = 'Offered')) AS `Offered`,sum((`a`.`Status` = 'Accepted')) AS `Accepted`,sum((`a`.`Status` = 'Rejected')) AS `Rejected`,round(((sum((`a`.`Status` = 'Accepted')) / nullif(count(`a`.`ApplicationID`),0)) * 100),1) AS `AcceptanceRate` from ((`applications` `a` join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) where (`a`.`IsDeleted` = false) group by `p`.`PositionID`,`p`.`PositionName`,`e`.`EmployerName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_candidateanalytics`
--

/*!50001 DROP VIEW IF EXISTS `view_candidateanalytics`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_candidateanalytics` AS select `c`.`CandidateID` AS `CandidateID`,`c`.`Gender` AS `Gender`,ifnull(`fn_GetAge`(`c`.`DateOfBirth`),0) AS `Age`,`c`.`EducationLevel` AS `EducationLevel`,`c`.`GPA` AS `GPA`,`c`.`YearsOfExperience` AS `YearsOfExperience`,`p`.`JobType` AS `JobType`,`i`.`RoundNumber` AS `RoundNumber`,`i`.`InterviewType` AS `InterviewType`,`i`.`Score` AS `Score`,round(((`i`.`Score` / nullif(`i`.`MaxScore`,0)) * 100),2) AS `NormalizedScore`,`i`.`Result` AS `Result` from (((`candidates` `c` join `applications` `a` on(((`c`.`CandidateID` = `a`.`CandidateID`) and (`a`.`IsDeleted` = false)))) join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `interviews` `i` on(((`a`.`ApplicationID` = `i`.`ApplicationID`) and (`i`.`IsDeleted` = false)))) where ((`c`.`IsDeleted` = false) and (`i`.`Score` is not null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_employerrecruitmentstats`
--

/*!50001 DROP VIEW IF EXISTS `view_employerrecruitmentstats`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_employerrecruitmentstats` AS select `e`.`EmployerID` AS `EmployerID`,`e`.`EmployerName` AS `EmployerName`,count(distinct `p`.`PositionID`) AS `TotalPositions`,count(distinct `a`.`ApplicationID`) AS `TotalApplications`,count(distinct `i`.`InterviewID`) AS `TotalInterviews`,count(distinct (case when (`a`.`Status` = 'Accepted') then `a`.`ApplicationID` end)) AS `Hires`,round(avg(`i`.`Score`),2) AS `AvgInterviewScore` from (((`employers` `e` left join `jobpositions` `p` on(((`e`.`EmployerID` = `p`.`EmployerID`) and (`p`.`IsDeleted` = false)))) left join `applications` `a` on(((`p`.`PositionID` = `a`.`PositionID`) and (`a`.`IsDeleted` = false)))) left join `interviews` `i` on(((`a`.`ApplicationID` = `i`.`ApplicationID`) and (`i`.`IsDeleted` = false)))) where (`e`.`IsDeleted` = false) group by `e`.`EmployerID`,`e`.`EmployerName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_interviewerworkload`
--

/*!50001 DROP VIEW IF EXISTS `view_interviewerworkload`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_interviewerworkload` AS select `iv`.`InterviewerID` AS `InterviewerID`,`iv`.`FullName` AS `FullName`,`e`.`EmployerName` AS `EmployerName`,count(distinct `i`.`InterviewID`) AS `TotalInterviews`,count(distinct `a`.`CandidateID`) AS `UniqueCandidates`,round(avg(`i`.`Score`),2) AS `AvgGivenScore`,sum((`i`.`Result` = 'Pass')) AS `Passes`,sum((`i`.`Result` = 'Fail')) AS `Fails` from ((((`interviewers` `iv` join `employers` `e` on(((`iv`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) left join `interviewpanel` `ip` on((`iv`.`InterviewerID` = `ip`.`InterviewerID`))) left join `interviews` `i` on(((`ip`.`InterviewID` = `i`.`InterviewID`) and (`i`.`IsDeleted` = false)))) left join `applications` `a` on(((`i`.`ApplicationID` = `a`.`ApplicationID`) and (`a`.`IsDeleted` = false)))) where (`iv`.`IsDeleted` = false) group by `iv`.`InterviewerID`,`iv`.`FullName`,`e`.`EmployerName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_interviewresults`
--

/*!50001 DROP VIEW IF EXISTS `view_interviewresults`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_interviewresults` AS select `c`.`CandidateID` AS `CandidateID`,`c`.`CandidateName` AS `CandidateName`,`c`.`Email` AS `CandidateEmail`,`e`.`EmployerName` AS `EmployerName`,`p`.`PositionName` AS `PositionName`,`i`.`RoundNumber` AS `RoundNumber`,`i`.`InterviewType` AS `InterviewType`,`i`.`InterviewDate` AS `InterviewDate`,`iv`.`FullName` AS `InterviewerName`,`i`.`Score` AS `Score`,`i`.`MaxScore` AS `MaxScore`,round(((`i`.`Score` / nullif(`i`.`MaxScore`,0)) * 100),1) AS `ScorePct`,`i`.`Result` AS `Result`,`i`.`Note` AS `Note` from (((((`interviews` `i` join `applications` `a` on(((`i`.`ApplicationID` = `a`.`ApplicationID`) and (`a`.`IsDeleted` = false)))) join `candidates` `c` on(((`a`.`CandidateID` = `c`.`CandidateID`) and (`c`.`IsDeleted` = false)))) join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) left join `interviewers` `iv` on(((`i`.`InterviewerID` = `iv`.`InterviewerID`) and (`iv`.`IsDeleted` = false)))) where (`i`.`IsDeleted` = false) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_monthlyrecruitmentfunnel`
--

/*!50001 DROP VIEW IF EXISTS `view_monthlyrecruitmentfunnel`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_monthlyrecruitmentfunnel` AS select date_format(`a`.`ApplicationDate`,'%Y-%m') AS `Month`,`p`.`EmployerID` AS `EmployerID`,`e`.`EmployerName` AS `EmployerName`,count(`a`.`ApplicationID`) AS `Applications`,sum((`a`.`Status` in ('Screening','Interviewing','Offered','Accepted'))) AS `MovedForward`,sum((`a`.`Status` = 'Accepted')) AS `Hired` from ((`applications` `a` join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) where (`a`.`IsDeleted` = false) group by `Month`,`p`.`EmployerID`,`e`.`EmployerName` order by `Month` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_openpositions`
--

/*!50001 DROP VIEW IF EXISTS `view_openpositions`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_openpositions` AS select `p`.`PositionID` AS `PositionID`,`p`.`PositionName` AS `PositionName`,`e`.`EmployerName` AS `EmployerName`,`ind`.`IndustryName` AS `IndustryName`,`p`.`JobType` AS `JobType`,`p`.`Location` AS `Location`,`p`.`SalaryMin` AS `SalaryMin`,`p`.`SalaryMax` AS `SalaryMax`,`p`.`ExperienceYears` AS `ExperienceYears`,`p`.`EducationLevel` AS `EducationLevel`,`p`.`Deadline` AS `Deadline` from ((`jobpositions` `p` join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) left join `industries` `ind` on(((`e`.`IndustryID` = `ind`.`IndustryID`) and (`ind`.`IsDeleted` = false)))) where ((`p`.`Status` = 'Open') and (`p`.`IsDeleted` = false)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_shortlistedcandidates`
--

/*!50001 DROP VIEW IF EXISTS `view_shortlistedcandidates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_shortlistedcandidates` AS select `c`.`CandidateID` AS `CandidateID`,`c`.`CandidateName` AS `CandidateName`,`c`.`Email` AS `Email`,`c`.`PhoneNumber` AS `PhoneNumber`,`p`.`PositionName` AS `PositionName`,`e`.`EmployerName` AS `EmployerName`,`a`.`ApplicationDate` AS `ApplicationDate`,`a`.`Status` AS `Status` from (((`applications` `a` join `candidates` `c` on(((`a`.`CandidateID` = `c`.`CandidateID`) and (`c`.`IsDeleted` = false)))) join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) where ((`a`.`Status` in ('Screening','Interviewing','Offered','Accepted')) and (`a`.`IsDeleted` = false)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_stageconversionrates`
--

/*!50001 DROP VIEW IF EXISTS `view_stageconversionrates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_stageconversionrates` AS select `p`.`PositionID` AS `PositionID`,`p`.`PositionName` AS `PositionName`,`e`.`EmployerName` AS `EmployerName`,count(`a`.`ApplicationID`) AS `TotalApplied`,sum((`a`.`Status` in ('Screening','Interviewing','Offered','Accepted'))) AS `Screened`,sum((`a`.`Status` in ('Interviewing','Offered','Accepted'))) AS `Interviewed`,sum((`a`.`Status` in ('Offered','Accepted'))) AS `OfferedCount`,sum((`a`.`Status` = 'Accepted')) AS `Hired`,round(((sum((`a`.`Status` in ('Screening','Interviewing','Offered','Accepted'))) / nullif(count(`a`.`ApplicationID`),0)) * 100),1) AS `ScreeningRate`,round(((sum((`a`.`Status` in ('Interviewing','Offered','Accepted'))) / nullif(sum((`a`.`Status` in ('Screening','Interviewing','Offered','Accepted'))),0)) * 100),1) AS `InterviewRate`,round(((sum((`a`.`Status` in ('Offered','Accepted'))) / nullif(sum((`a`.`Status` in ('Interviewing','Offered','Accepted'))),0)) * 100),1) AS `OfferRate`,round(((sum((`a`.`Status` = 'Accepted')) / nullif(sum((`a`.`Status` in ('Offered','Accepted'))),0)) * 100),1) AS `AcceptanceRate` from ((`applications` `a` join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) where (`a`.`IsDeleted` = false) group by `p`.`PositionID`,`p`.`PositionName`,`e`.`EmployerName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `view_topcandidates`
--

/*!50001 DROP VIEW IF EXISTS `view_topcandidates`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `view_topcandidates` AS select `p`.`PositionName` AS `PositionName`,`e`.`EmployerName` AS `EmployerName`,`c`.`CandidateName` AS `CandidateName`,round(avg(`i`.`Score`),2) AS `AvgScore`,count(`i`.`InterviewID`) AS `TotalRounds`,rank() OVER (PARTITION BY `p`.`PositionID` ORDER BY avg(`i`.`Score`) desc )  AS `RankNum`,`a`.`Status` AS `ApplicationStatus` from ((((`interviews` `i` join `applications` `a` on(((`i`.`ApplicationID` = `a`.`ApplicationID`) and (`a`.`IsDeleted` = false)))) join `candidates` `c` on(((`a`.`CandidateID` = `c`.`CandidateID`) and (`c`.`IsDeleted` = false)))) join `jobpositions` `p` on(((`a`.`PositionID` = `p`.`PositionID`) and (`p`.`IsDeleted` = false)))) join `employers` `e` on(((`p`.`EmployerID` = `e`.`EmployerID`) and (`e`.`IsDeleted` = false)))) where (`i`.`IsDeleted` = false) group by `p`.`PositionID`,`p`.`PositionName`,`e`.`EmployerName`,`c`.`CandidateID`,`c`.`CandidateName`,`a`.`Status` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-06 11:39:57

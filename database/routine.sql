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
-- Dumping routines for database 'recruitmentdb'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_AvgInterviewScore` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_AvgInterviewScore`(p_ApplicationID INT) RETURNS decimal(5,2)
    READS SQL DATA
BEGIN
    DECLARE v_Avg DECIMAL(5,2) DEFAULT 0.00;
    SELECT ROUND(AVG(Score), 2) INTO v_Avg FROM Interviews
    WHERE ApplicationID = p_ApplicationID AND Score IS NOT NULL AND IsDeleted = FALSE;
    RETURN IFNULL(v_Avg, 0.00);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_CountApplications` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_CountApplications`(p_PositionID INT) RETURNS int
    READS SQL DATA
BEGIN
    DECLARE v_Count INT DEFAULT 0;
    SELECT COUNT(*) INTO v_Count FROM Applications WHERE PositionID = p_PositionID AND IsDeleted = FALSE;
    RETURN v_Count;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_GetAge` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_GetAge`(p_DateOfBirth DATE) RETURNS int
    DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, p_DateOfBirth, CURDATE());
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_IsEligible` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_IsEligible`(p_CandidateID INT, p_PositionID INT) RETURNS varchar(50) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    READS SQL DATA
BEGIN
    DECLARE v_CandExp  INT DEFAULT 0;
    DECLARE v_RequiredExp INT DEFAULT 0;

    DECLARE v_CandEdu  VARCHAR(20);   -- bảng gốc dùng VARCHAR(20)
    DECLARE v_RequiredEdu VARCHAR(20);

    DECLARE v_CandEduWeight INT DEFAULT 0;
    DECLARE v_RequiredEduWeight INT DEFAULT 0;

    SELECT IFNULL(YearsOfExperience, 0), IFNULL(EducationLevel, 'High School')
    INTO   v_CandExp, v_CandEdu
    FROM   Candidates
    WHERE  CandidateID = p_CandidateID AND IsDeleted = FALSE
    LIMIT  1;

    SELECT IFNULL(ExperienceYears, 0), IFNULL(EducationLevel, 'Any')
    INTO   v_RequiredExp, v_RequiredEdu
    FROM   JobPositions
    WHERE  PositionID = p_PositionID AND IsDeleted = FALSE
    LIMIT  1;

    SET v_CandEduWeight = CASE v_CandEdu
        WHEN 'High School' THEN 1
        WHEN 'Associate'   THEN 2
        WHEN 'Bachelor'    THEN 3
        WHEN 'Master'      THEN 4
        WHEN 'PhD'         THEN 5
        ELSE 1 END;

    SET v_RequiredEduWeight = CASE v_RequiredEdu
        WHEN 'Any'         THEN 0
        WHEN 'High School' THEN 1
        WHEN 'Associate'   THEN 2
        WHEN 'Bachelor'    THEN 3
        WHEN 'Master'      THEN 4
        WHEN 'PhD'         THEN 5
        ELSE 0 END;

    IF v_CandExp < v_RequiredExp THEN
        RETURN 'Not Eligible (Experience)';
    ELSEIF v_CandEduWeight < v_RequiredEduWeight THEN
        RETURN 'Not Eligible (Education)';
    ELSE
        RETURN 'Eligible';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `fn_PassRate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_PassRate`(p_CandidateID INT) RETURNS decimal(5,2)
    READS SQL DATA
BEGIN
    DECLARE v_Total  INT DEFAULT 0;
    DECLARE v_Passed INT DEFAULT 0;
    SELECT COUNT(*), IFNULL(SUM(i.Result = 'Pass'), 0) INTO v_Total, v_Passed
    FROM Interviews i
    JOIN Applications a ON i.ApplicationID = a.ApplicationID
    WHERE a.CandidateID = p_CandidateID AND a.IsDeleted = FALSE AND i.IsDeleted = FALSE AND i.Result != 'Pending';
    IF v_Total = 0 THEN RETURN 0.00; END IF;
    RETURN ROUND(v_Passed / v_Total * 100, 2);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AcceptOffer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AcceptOffer`(
    IN p_ApplicationID INT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    DECLARE v_OfferID INT;
    DECLARE v_CandidateID INT;

    SELECT jo.OfferID, a.CandidateID INTO v_OfferID, v_CandidateID
    FROM JobOffers jo
    JOIN Applications a ON jo.ApplicationID = a.ApplicationID
    WHERE jo.ApplicationID = p_ApplicationID AND jo.Status = 'Pending';

    IF v_OfferID IS NULL THEN
        SET p_Result = 'Error: No pending offer found for this application.';
    ELSE
        UPDATE JobOffers SET Status = 'Accepted' WHERE OfferID = v_OfferID;
        UPDATE Applications SET Status = 'Accepted' WHERE ApplicationID = p_ApplicationID;
        -- Không cần trigger cho notification vì application status thay đổi sẽ kích hoạt trigger
        SET p_Result = 'Offer accepted successfully.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddCandidateSkill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddCandidateSkill`(
    IN p_CandidateID INT, 
    IN p_SkillID INT, 
    IN p_ProficiencyLevel VARCHAR(20), 
    IN p_YearsUsed DECIMAL(4,1),
    OUT p_Result VARCHAR(100)
)
BEGIN
    INSERT INTO CandidateSkills (CandidateID, SkillID, ProficiencyLevel, YearsUsed)
    VALUES (p_CandidateID, p_SkillID, p_ProficiencyLevel, p_YearsUsed)
    ON DUPLICATE KEY UPDATE 
        ProficiencyLevel = VALUES(ProficiencyLevel), 
        YearsUsed = VALUES(YearsUsed);
    
    SET p_Result = 'SUCCESS: Skill added/updated.';
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AddJobRequirement` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddJobRequirement`(
    IN p_PositionID INT, 
    IN p_SkillID INT, 
    IN p_RequiredLevel VARCHAR(20), 
    IN p_IsMandatory BOOLEAN
)
BEGIN
    INSERT INTO JobRequirements (PositionID, SkillID, RequiredLevel, IsMandatory) 
    VALUES (p_PositionID, p_SkillID, p_RequiredLevel, p_IsMandatory);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AdminLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AdminLogin`(
    IN p_Email VARCHAR(150),
    IN p_PasswordHash VARCHAR(255),
    OUT p_AdminID INT,
    OUT p_Result VARCHAR(50)
)
BEGIN
    DECLARE v_DBPassword VARCHAR(255);
    DECLARE v_IsActive BOOLEAN;

    SELECT AdminID, PasswordHash, IsActive 
    INTO p_AdminID, v_DBPassword, v_IsActive
    FROM Admin_Accounts WHERE Email = p_Email;

    IF p_AdminID IS NULL THEN
        SET p_Result = 'Account not found';
    ELSEIF v_IsActive = FALSE THEN
        SET p_Result = 'Account locked';
    ELSEIF p_PasswordHash = v_DBPassword THEN
        SET p_Result = 'Login successful';
    ELSE
        SET p_AdminID = NULL;
        SET p_Result = 'Invalid password';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_AnalystLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AnalystLogin`(
    IN p_Email VARCHAR(150),
    IN p_PasswordHash VARCHAR(255),
    OUT p_AnalystID INT,
    OUT p_Result VARCHAR(50)
)
BEGIN
    DECLARE v_DBPassword VARCHAR(255);
    DECLARE v_IsActive BOOLEAN;

    SELECT AnalystID, PasswordHash, IsActive 
    INTO p_AnalystID, v_DBPassword, v_IsActive
    FROM Analyst_Accounts WHERE Email = p_Email;

    IF p_AnalystID IS NULL THEN
        SET p_Result = 'Account not found';
    ELSEIF v_IsActive = FALSE THEN
        SET p_Result = 'Account locked';
    ELSEIF p_PasswordHash = v_DBPassword THEN
        SET p_Result = 'Login successful';
    ELSE
        SET p_AnalystID = NULL;
        SET p_Result = 'Invalid password';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_BackupApplications` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BackupApplications`()
BEGIN
    INSERT INTO Applications_Archive (ApplicationID, CandidateID, PositionID, ApplicationDate, Status)
    SELECT ApplicationID, CandidateID, PositionID, ApplicationDate, Status
    FROM Applications
    WHERE IsDeleted = FALSE;
    
    SELECT CONCAT('Backup completed: ', ROW_COUNT(), ' rows archived.') AS Result;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CandidateApply` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CandidateApply`(
    IN  p_CandidateID INT,
    IN  p_PositionID INT,
    IN  p_CoverLetter TEXT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    DECLARE v_CoverLetter TEXT DEFAULT '';
    IF p_CoverLetter IS NOT NULL THEN
        SET v_CoverLetter = p_CoverLetter;
    ELSE
        SET v_CoverLetter = 'Nộp hồ sơ nhanh qua hệ thống.';
    END IF;
    CALL sp_SubmitApplication(p_CandidateID, p_PositionID, v_CoverLetter, p_Result);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CandidateDashboard` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CandidateDashboard`(IN p_CandidateID INT)
BEGIN
    SELECT
        COUNT(*) AS TotalApplications,
        SUM(CASE WHEN Status = 'Applied' THEN 1 ELSE 0 END) AS Applied,
        SUM(CASE WHEN Status = 'Screening' THEN 1 ELSE 0 END) AS Screening,
        SUM(CASE WHEN Status = 'Interviewing' THEN 1 ELSE 0 END) AS Interviewing,
        SUM(CASE WHEN Status = 'Offered' THEN 1 ELSE 0 END) AS Offered,
        SUM(CASE WHEN Status = 'Accepted' THEN 1 ELSE 0 END) AS Accepted,
        SUM(CASE WHEN Status = 'Rejected' THEN 1 ELSE 0 END) AS Rejected,
        SUM(CASE WHEN Status = 'Withdrawn' THEN 1 ELSE 0 END) AS Withdrawn
    FROM Applications
    WHERE CandidateID = p_CandidateID AND IsDeleted = FALSE;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CandidateLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CandidateLogin`(
    IN  p_Email VARCHAR(150),
    IN  p_PasswordHash VARCHAR(255),
    OUT p_CandidateID INT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    SELECT c.CandidateID INTO p_CandidateID
    FROM Candidates c
    JOIN CandidateAccounts ca ON c.CandidateID = ca.CandidateID
    WHERE ca.Email = p_Email AND ca.PasswordHash = p_PasswordHash AND ca.IsActive = TRUE AND c.IsDeleted = FALSE;
    IF p_CandidateID IS NULL THEN
        SET p_Result = 'ERROR: Invalid credentials.';
    ELSE
        SET p_Result = 'SUCCESS: Authenticated.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CandidateUpdateProfile` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CandidateUpdateProfile`(
    IN  p_CandidateID INT,
    IN  p_PhoneNumber VARCHAR(20),
    IN  p_Address VARCHAR(300),
    IN  p_EducationLevel VARCHAR(20),
    IN  p_GPA DECIMAL(4,2),
    IN  p_YearsOfExperience INT,
    IN  p_ResumeURL VARCHAR(500),
    OUT p_Result VARCHAR(100)
)
BEGIN
    UPDATE Candidates
    SET PhoneNumber = p_PhoneNumber,
        Address = p_Address,
        EducationLevel = p_EducationLevel,
        GPA = p_GPA,
        YearsOfExperience = p_YearsOfExperience,
        ResumeURL = p_ResumeURL
    WHERE CandidateID = p_CandidateID AND IsDeleted = FALSE;
    IF ROW_COUNT() = 0 THEN
        SET p_Result = 'ERROR: Candidate not found.';
    ELSE
        SET p_Result = 'SUCCESS: Profile updated.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CreateJob` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateJob`(
    IN p_EmployerID INT,
    IN p_DepartmentID INT,
    IN p_PositionName VARCHAR(255),
    IN p_JobType VARCHAR(50),
    IN p_SalaryMin DECIMAL(10,2),
    IN p_SalaryMax DECIMAL(10,2),
    IN p_ExperienceYears INT,
    IN p_EducationLevel VARCHAR(100),
    IN p_Location VARCHAR(255),
    IN p_Openings INT,
    IN p_MaxRounds INT,
    IN p_Deadline DATE,
    IN p_Status VARCHAR(50),
    OUT p_Result VARCHAR(100)
)
BEGIN
    INSERT INTO JobPositions (
        EmployerID, DepartmentID, PositionName, JobType, 
        SalaryMin, SalaryMax, ExperienceYears, EducationLevel, 
        Location, Openings, MaxRounds, Deadline, Status, IsDeleted
    ) VALUES (
        p_EmployerID, p_DepartmentID, p_PositionName, p_JobType,
        p_SalaryMin, p_SalaryMax, p_ExperienceYears, p_EducationLevel,
        p_Location, p_Openings, p_MaxRounds, p_Deadline, p_Status, FALSE
    );
    SET p_Result = LAST_INSERT_ID();
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_CreateOffer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateOffer`(
    IN p_ApplicationID INT,
    IN p_EmployerID INT,
    IN p_BasicSalary DECIMAL(15,2),
    IN p_OfferDate DATE,
    IN p_ValidUntil DATE,
    IN p_Note TEXT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    -- Kiểm tra application thuộc employer
    IF NOT EXISTS(SELECT 1 FROM Applications a JOIN JobPositions jp ON a.PositionID = jp.PositionID
                  WHERE a.ApplicationID = p_ApplicationID AND jp.EmployerID = p_EmployerID) THEN
        SET p_Result = 'Error: Unauthorized or Application not found.';
    ELSE
        -- Tạo offer
        INSERT INTO JobOffers (ApplicationID, BasicSalary, OfferDate, ValidUntil, Note, Status)
        VALUES (p_ApplicationID, p_BasicSalary, p_OfferDate, p_ValidUntil, p_Note, 'Pending');
        -- Cập nhật trạng thái application sang Offered (quan trọng)
        UPDATE Applications SET Status = 'Offered' WHERE ApplicationID = p_ApplicationID;
        SET p_Result = 'Offer created successfully.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_DeclineOffer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeclineOffer`(
    IN p_ApplicationID INT, 
    IN p_CandidateID INT, 
    OUT p_Result VARCHAR(100)
)
BEGIN
    IF EXISTS(
        SELECT 1 FROM JobOffers jo
        JOIN Applications a ON jo.ApplicationID = a.ApplicationID
        WHERE a.ApplicationID = p_ApplicationID AND a.CandidateID = p_CandidateID
    ) THEN
        UPDATE JobOffers SET Status = 'Declined' WHERE ApplicationID = p_ApplicationID;
        SET p_Result = 'Offer declined successfully';
    ELSE
        SET p_Result = 'Error: Offer not found or unauthorized';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GenerateSampleData` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GenerateSampleData`()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE j INT DEFAULT 1;
    DECLARE total_candidates INT DEFAULT 100;
    DECLARE total_jobs INT DEFAULT 30;
    DECLARE total_applications INT DEFAULT 150;
    DECLARE total_interviewers INT DEFAULT 20;
    DECLARE total_interviews INT DEFAULT 80;
    DECLARE total_offers INT DEFAULT 25;

    DECLARE v_emp_id INT;
    DECLARE v_dept_id INT;
    DECLARE v_cand_id INT;
    DECLARE v_pos_id INT;

    SET FOREIGN_KEY_CHECKS = 0;
    SET SQL_SAFE_UPDATES = 0;

    -- Xoá sạch
    TRUNCATE TABLE InterviewLog;
    TRUNCATE TABLE ApplicationStatusLog;
    DELETE FROM InterviewPanel;
    DELETE FROM JobOffers;
    DELETE FROM Interviews;
    DELETE FROM Interviewers;
    DELETE FROM Applications;
    DELETE FROM CandidateSkills;
    DELETE FROM JobRequirements;
    DELETE FROM JobPositions;
    DELETE FROM Candidates;
    DELETE FROM Skills;
    DELETE FROM Departments;
    DELETE FROM Employers;
    DELETE FROM Industries;

    ALTER TABLE Industries AUTO_INCREMENT = 1;
    ALTER TABLE Skills AUTO_INCREMENT = 1;
    ALTER TABLE Candidates AUTO_INCREMENT = 1;
    ALTER TABLE Employers AUTO_INCREMENT = 1;
    ALTER TABLE Departments AUTO_INCREMENT = 1;
    ALTER TABLE JobPositions AUTO_INCREMENT = 1;
    ALTER TABLE Applications AUTO_INCREMENT = 1;
    ALTER TABLE Interviewers AUTO_INCREMENT = 1;
    ALTER TABLE Interviews AUTO_INCREMENT = 1;
    ALTER TABLE JobOffers AUTO_INCREMENT = 1;

    SET FOREIGN_KEY_CHECKS = 1;

    -- Industries
    INSERT INTO Industries (IndustryName, Description) VALUES
    ('Information Technology', 'IT services and software'),
    ('Marketing & Advertising', 'Digital marketing'),
    ('Finance & Banking', 'Banking, fintech'),
    ('Healthcare', 'Hospitals and medical equipment'),
    ('Education', 'Training and e-learning'),
    ('Manufacturing', 'Production and logistics'),
    ('Retail', 'Consumer goods and sales'),
    ('Telecommunications', 'Mobile and internet'),
    ('Hospitality', 'Hotel and tourism'),
    ('Construction', 'Real estate and infrastructure');

    -- Skills (tên duy nhất, không UPDATE)
    SET i = 1;
    WHILE i <= 5 DO
        INSERT INTO Skills (SkillName, Category) VALUES (CONCAT('Python', i), 'Programming');
        SET i = i + 1;
    END WHILE;
    SET i = 6;
    WHILE i <= 10 DO
        INSERT INTO Skills (SkillName, Category) VALUES (CONCAT('Java', i), 'Programming');
        SET i = i + 1;
    END WHILE;
    SET i = 11;
    WHILE i <= 15 DO
        INSERT INTO Skills (SkillName, Category) VALUES (CONCAT('SQL', i), 'Database');
        SET i = i + 1;
    END WHILE;
    SET i = 16;
    WHILE i <= 20 DO
        INSERT INTO Skills (SkillName, Category) VALUES (CONCAT('Skill_', i),
            CASE FLOOR(RAND()*2) WHEN 0 THEN 'Soft Skills' ELSE 'Design' END);
        SET i = i + 1;
    END WHILE;
    INSERT INTO Skills (SkillName, Category) VALUES
    ('Python','Programming'),('Java','Programming'),('SQL','Database'),
    ('Project Management','Soft Skills'),('UI/UX Design','Design');

    -- Employers & Departments
    SET i = 1;
    WHILE i <= 12 DO
        INSERT INTO Employers (EmployerName, IndustryID, Email, CompanySize)
        VALUES (
            CONCAT('Company_', i),
            (SELECT IndustryID FROM Industries ORDER BY RAND() LIMIT 1),
            CONCAT('hr', i, '@company', i, '.com'),
            ELT(FLOOR(1+RAND()*5), 'Startup','Small','Medium','Large','Enterprise')
        );
        SET v_emp_id = LAST_INSERT_ID();
        SET j = 1;
        WHILE j <= 1 + FLOOR(RAND()*3) DO
            INSERT INTO Departments (EmployerID, DepartmentName) VALUES (v_emp_id, CONCAT('Dept_', j, '_Emp', i));
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    -- Candidates
    SET i = 1;
    WHILE i <= total_candidates DO
        INSERT INTO Candidates (CandidateName, Gender, DateOfBirth, Email, EducationLevel, GPA, YearsOfExperience)
        VALUES (
            CONCAT('Candidate_', i, ' ', CHAR(65 + FLOOR(RAND()*26)), '.'),
            ELT(FLOOR(1+RAND()*3), 'Male','Female','Other'),
            DATE_ADD('1975-01-01', INTERVAL FLOOR(RAND()*30*365) DAY),
            CONCAT('cand', i, '@example.com'),
            ELT(FLOOR(1+RAND()*4), 'Bachelor','Master','PhD','Associate'),
            ROUND(2.0 + RAND()*2.0, 2),
            FLOOR(RAND()*15)
        );
        SET i = i + 1;
    END WHILE;

    -- CandidateSkills
    SET i = 1;
    WHILE i <= total_candidates DO
        SET j = 1;
        WHILE j <= 1 + FLOOR(RAND()*3) DO
            INSERT IGNORE INTO CandidateSkills (CandidateID, SkillID, ProficiencyLevel, YearsUsed)
            VALUES (
                i,
                (SELECT SkillID FROM Skills ORDER BY RAND() LIMIT 1),
                ELT(FLOOR(1+RAND()*3), 'Beginner','Intermediate','Advanced'),
                ROUND(RAND()*10, 1)
            );
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    -- JobPositions (lương an toàn)
    SET i = 1;
    WHILE i <= total_jobs DO
        SELECT e.EmployerID INTO v_emp_id FROM Employers e ORDER BY RAND() LIMIT 1;
        SELECT d.DepartmentID INTO v_dept_id FROM Departments d WHERE d.EmployerID = v_emp_id ORDER BY RAND() LIMIT 1;

        SET @base = FLOOR(5000000 + RAND() * 15000000);
        SET @range = FLOOR(1 + RAND() * 15000000);
        INSERT INTO JobPositions (EmployerID, DepartmentID, PositionName, JobType, SalaryMin, SalaryMax,
                                  ExperienceYears, EducationLevel, Openings, MaxRounds, Deadline)
        VALUES (
            v_emp_id,
            v_dept_id,
            CONCAT('Position_', i),
            ELT(FLOOR(1+RAND()*5), 'Full-time','Part-time','Contract','Internship','Remote'),
            @base,
            @base + @range,
            FLOOR(RAND()*10),
            ELT(FLOOR(1+RAND()*5), 'Any','Bachelor','Master','PhD','High School'),
            1 + FLOOR(RAND()*5),
            1 + FLOOR(RAND()*3),
            IF(RAND()>0.3, DATE_ADD(CURDATE(), INTERVAL FLOOR(30+RAND()*60) DAY), NULL)
        );
        SET i = i + 1;
    END WHILE;

    -- JobRequirements
    SET i = 1;
    WHILE i <= total_jobs DO
        SET j = 1;
        WHILE j <= 1 + FLOOR(RAND()*3) DO
            INSERT IGNORE INTO JobRequirements (PositionID, SkillID, RequiredLevel, IsMandatory)
            VALUES (
                i,
                (SELECT SkillID FROM Skills ORDER BY RAND() LIMIT 1),
                ELT(FLOOR(1+RAND()*3), 'Beginner','Intermediate','Advanced'),
                RAND() > 0.2
            );
            SET j = j + 1;
        END WHILE;
        SET i = i + 1;
    END WHILE;

    -- Applications
    SET i = 1;
    WHILE i <= total_applications DO
        SELECT CandidateID INTO v_cand_id FROM Candidates ORDER BY RAND() LIMIT 1;
        SELECT PositionID INTO v_pos_id FROM JobPositions ORDER BY RAND() LIMIT 1;

        INSERT INTO Applications (CandidateID, PositionID, ApplicationDate, Status)
        VALUES (
            v_cand_id,
            v_pos_id,
            DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND()*150) DAY),
            ELT(FLOOR(1+RAND()*7), 'Applied','Screening','Interviewing','Offered','Accepted','Rejected','Withdrawn')
        );
        SET i = i + 1;
    END WHILE;

    -- Đa dạng trạng thái
    UPDATE Applications SET Status = 'Interviewing' WHERE ApplicationID % 5 = 0 AND Status = 'Applied';
    UPDATE Applications SET Status = 'Offered' WHERE ApplicationID % 10 = 0 AND Status = 'Interviewing';
    UPDATE Applications SET Status = 'Accepted' WHERE ApplicationID % 15 = 0 AND Status = 'Offered';
    UPDATE Applications SET Status = 'Rejected' WHERE ApplicationID % 7 = 0 AND Status IN ('Applied','Screening');

    -- Interviewers
    SET i = 1;
    WHILE i <= total_interviewers DO
        INSERT INTO Interviewers (EmployerID, FullName, Email, JobTitle)
        VALUES (
            (SELECT EmployerID FROM Employers ORDER BY RAND() LIMIT 1),
            CONCAT('Interviewer_', i, ' ', CHAR(65 + FLOOR(RAND()*26))),
            CONCAT('iv', i, '@interviewer.com'),
            ELT(FLOOR(1+RAND()*4), 'HR Specialist','Tech Lead','Senior Engineer','Manager')
        );
        SET i = i + 1;
    END WHILE;

    -- Interviews & InterviewPanel
    SET i = 1;
    WHILE i <= total_interviews DO
        SELECT ApplicationID INTO v_cand_id FROM Applications
            WHERE Status IN ('Interviewing','Offered','Accepted','Rejected','Screening') ORDER BY RAND() LIMIT 1;
        IF v_cand_id IS NULL THEN
            SELECT ApplicationID INTO v_cand_id FROM Applications ORDER BY RAND() LIMIT 1;
        END IF;

        INSERT INTO Interviews (ApplicationID, InterviewerID, InterviewDate, RoundNumber, InterviewType, Score, Result)
        VALUES (
            v_cand_id,
            (SELECT InterviewerID FROM Interviewers ORDER BY RAND() LIMIT 1),
            DATE_ADD(NOW(), INTERVAL FLOOR(RAND()*30) DAY),
            1 + FLOOR(RAND()*3),
            ELT(FLOOR(1+RAND()*5), 'Phone','Online','In-person','Technical','HR'),
            IF(RAND()>0.3, ROUND(40+RAND()*60, 2), NULL),
            ELT(FLOOR(1+RAND()*3), 'Pass','Fail','Pending')
        );
        INSERT INTO InterviewPanel (InterviewID, InterviewerID, Role)
        VALUES (LAST_INSERT_ID(), (SELECT InterviewerID FROM Interviewers ORDER BY RAND() LIMIT 1), 'Lead');
        IF RAND() > 0.5 THEN
            INSERT IGNORE INTO InterviewPanel (InterviewID, InterviewerID, Role)
            VALUES (LAST_INSERT_ID(), (SELECT InterviewerID FROM Interviewers ORDER BY RAND() LIMIT 1), 'Panelist');
        END IF;
        SET i = i + 1;
    END WHILE;

    -- JobOffers
    SET i = 1;
    WHILE i <= total_offers DO
        INSERT INTO JobOffers (ApplicationID, BasicSalary, OfferDate, ValidUntil, Status)
        SELECT
            a.ApplicationID,
            p.SalaryMin + FLOOR(RAND()*(p.SalaryMax - p.SalaryMin)),
            CURDATE(),
            DATE_ADD(CURDATE(), INTERVAL 7 DAY),
            'Pending'
        FROM Applications a
        JOIN JobPositions p ON a.PositionID = p.PositionID
        WHERE a.Status = 'Offered'
          AND NOT EXISTS (SELECT 1 FROM JobOffers o WHERE o.ApplicationID = a.ApplicationID)
        ORDER BY RAND() LIMIT 1;
        IF ROW_COUNT() = 0 THEN
            SET i = i + 1;
        ELSE
            SET i = i + 1;
        END IF;
        IF i > 50 THEN SET i = total_offers + 1; END IF;
    END WHILE;

    -- ================== CandidateAccounts (tạo tài khoản cho tất cả ứng viên) ==================
    INSERT INTO CandidateAccounts (CandidateID, Email, PasswordHash)
    SELECT CandidateID, Email, 'hashed_demo_password_123'
    FROM Candidates
    WHERE IsDeleted = FALSE;
    
    SET SQL_SAFE_UPDATES = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetMyApplications` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMyApplications`(IN p_CandidateID INT)
BEGIN
    SELECT 
        a.ApplicationID,
        p.PositionID,  -- Đảm bảo có dòng này
        p.PositionName,
        e.EmployerName,
        a.ApplicationDate,
        a.Status
    FROM Applications a
    JOIN JobPositions p ON a.PositionID = p.PositionID
    JOIN Employers e ON p.EmployerID = e.EmployerID
    WHERE a.CandidateID = p_CandidateID AND a.IsDeleted = FALSE
    ORDER BY a.ApplicationDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetMyInterviews` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMyInterviews`(IN p_CandidateID INT)
BEGIN
    SELECT 
        i.InterviewID,
        p.PositionName,
        i.InterviewDate,
        i.RoundNumber,
        i.InterviewType,
        i.Location,
        i.Result,
        i.Note,
        iv.FullName AS Interviewer
    FROM Interviews i
    JOIN Applications a ON i.ApplicationID = a.ApplicationID AND a.IsDeleted = FALSE
    JOIN JobPositions p ON a.PositionID = p.PositionID
    LEFT JOIN Interviewers iv ON i.InterviewerID = iv.InterviewerID
    WHERE a.CandidateID = p_CandidateID AND i.IsDeleted = FALSE
    ORDER BY i.InterviewDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetMyNotifications` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMyNotifications`(IN p_CandidateID INT)
BEGIN
    SELECT NotifID, Message, IsRead, CreatedAt
    FROM CandidateNotifications
    WHERE CandidateID = p_CandidateID
    ORDER BY CreatedAt DESC
    LIMIT 50;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetSavedJobs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSavedJobs`(IN p_CandidateID INT)
BEGIN
    SELECT 
        s.SavedID,
        p.PositionID,
        p.PositionName,
        e.EmployerName,
        p.JobType,
        p.Location,
        p.SalaryMin,
        p.SalaryMax,
        p.Deadline,
        s.SavedDate
    FROM SavedJobs s
    JOIN JobPositions p ON s.PositionID = p.PositionID AND p.IsDeleted = FALSE
    JOIN Employers e ON p.EmployerID = e.EmployerID AND e.IsDeleted = FALSE
    WHERE s.CandidateID = p_CandidateID
    ORDER BY s.SavedDate DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_HRLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_HRLogin`(
    IN p_Email VARCHAR(150),
    IN p_PasswordHash VARCHAR(255),
    OUT p_HR_ID INT,
    OUT p_EmployerID INT,
    OUT p_Result VARCHAR(50)
)
BEGIN
    DECLARE v_DBPassword VARCHAR(255);
    DECLARE v_IsActive BOOLEAN;

    SELECT HR_ID, EmployerID, PasswordHash, IsActive 
    INTO p_HR_ID, p_EmployerID, v_DBPassword, v_IsActive
    FROM HR_Accounts WHERE Email = p_Email;

    IF p_HR_ID IS NULL THEN
        SET p_Result = 'Account not found';
    ELSEIF v_IsActive = FALSE THEN
        SET p_Result = 'Account locked';
    ELSEIF p_PasswordHash = v_DBPassword THEN
        SET p_Result = 'Login successful';
    ELSE
        SET p_HR_ID = NULL;
        SET p_EmployerID = NULL;
        SET p_Result = 'Invalid password';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_InterviewerLogin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_InterviewerLogin`(
    IN p_Email VARCHAR(150),
    IN p_PasswordHash VARCHAR(255),
    OUT p_InterviewerID INT,
    OUT p_EmployerID INT,
    OUT p_Result VARCHAR(50)
)
BEGIN
    DECLARE v_DBPassword VARCHAR(255);
    DECLARE v_IsActive BOOLEAN;

    SELECT i.InterviewerID, i.EmployerID, a.PasswordHash, a.IsActive 
    INTO p_InterviewerID, p_EmployerID, v_DBPassword, v_IsActive
    FROM Interviewers i
    JOIN Interviewer_Accounts a ON i.InterviewerID = a.InterviewerID
    WHERE i.Email = p_Email AND i.IsDeleted = FALSE;

    IF p_InterviewerID IS NULL THEN
        SET p_Result = 'Account not found';
    ELSEIF v_IsActive = FALSE THEN
        SET p_Result = 'Account locked';
    ELSEIF p_PasswordHash = v_DBPassword THEN
        SET p_Result = 'Login successful';
    ELSE
        SET p_InterviewerID = NULL;
        SET p_EmployerID = NULL;
        SET p_Result = 'Invalid password';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_MarkNotificationRead` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MarkNotificationRead`(
    IN p_NotifID INT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    UPDATE CandidateNotifications
    SET IsRead = TRUE
    WHERE NotifID = p_NotifID AND IsRead = FALSE;
    
    IF ROW_COUNT() = 0 THEN
        SET p_Result = 'ERROR: Notification not found or already read.';
    ELSE
        SET p_Result = 'SUCCESS: Notification marked as read.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_MonthlyReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MonthlyReport`(IN p_Year INT, IN p_Month INT)
BEGIN
    SELECT
        e.EmployerName,
        p.PositionName,
        COUNT(a.ApplicationID)                                                   AS TotalApplications,
        SUM(a.Status = 'Accepted')                                               AS Accepted,
        SUM(a.Status = 'Rejected')                                               AS Rejected,
        ROUND(AVG(i.Score), 2)                                                   AS AvgScore,
        ROUND(
            SUM(a.Status = 'Accepted') / NULLIF(COUNT(a.ApplicationID), 0) * 100,
        1)                                                                       AS AcceptanceRate
    FROM   Applications a
    JOIN   JobPositions p  ON a.PositionID     = p.PositionID
    JOIN   Employers    e  ON p.EmployerID     = e.EmployerID
    LEFT JOIN Interviews i ON a.ApplicationID  = i.ApplicationID AND i.IsDeleted = FALSE
    WHERE  YEAR(a.ApplicationDate)  = p_Year
      AND  MONTH(a.ApplicationDate) = p_Month
      AND  a.IsDeleted = FALSE
      AND  p.IsDeleted = FALSE
    GROUP BY e.EmployerID, e.EmployerName, p.PositionID, p.PositionName
    ORDER BY e.EmployerName, TotalApplications DESC;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_RecordInterviewResult` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RecordInterviewResult`(
    IN  p_InterviewID INT,
    IN  p_Score       DECIMAL(5,2),
    IN  p_Result      VARCHAR(10),
    IN  p_Note        TEXT,
    OUT p_Response    VARCHAR(100)
)
BEGIN
    DECLARE v_MaxScore DECIMAL(5,2) DEFAULT 100;

    IF p_Result NOT IN ('Pass','Fail','Pending') THEN
        SET p_Response = 'ERROR: Result must be Pass, Fail, or Pending.';
    ELSE
        SELECT IFNULL(MaxScore, 100) INTO v_MaxScore
        FROM   Interviews
        WHERE  InterviewID = p_InterviewID AND IsDeleted = FALSE
        LIMIT  1;

        IF p_Score IS NOT NULL AND (p_Score < 0 OR p_Score > v_MaxScore) THEN
            SET p_Response = CONCAT('ERROR: Score must be between 0 and ', v_MaxScore, '.');
        ELSE
            UPDATE Interviews
            SET    Score  = p_Score,
                   Result = p_Result,
                   Note   = p_Note
            WHERE  InterviewID = p_InterviewID AND IsDeleted = FALSE;

            IF ROW_COUNT() = 0 THEN
                SET p_Response = 'ERROR: Interview not found.';
            ELSE
                SET p_Response = 'SUCCESS: Interview result recorded.';
            END IF;
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_RegisterCandidate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RegisterCandidate`(
    IN  p_CandidateName VARCHAR(100),
    IN  p_Gender VARCHAR(10),
    IN  p_DateOfBirth DATE,
    IN  p_Email VARCHAR(150),
    IN  p_PhoneNumber VARCHAR(20),
    IN  p_Address VARCHAR(300),
    IN  p_EducationLevel VARCHAR(20),
    IN  p_GPA DECIMAL(4,2),
    IN  p_YearsOfExperience INT,
    IN  p_PasswordHash VARCHAR(255),
    OUT p_Result VARCHAR(100)
)
BEGIN
    DECLARE v_NewCandidateID INT;
    -- Kiểm tra email trùng
    IF EXISTS (SELECT 1 FROM Candidates WHERE Email = p_Email AND IsDeleted = FALSE) THEN
        SET p_Result = 'ERROR: Email already exists.';
    ELSE
        INSERT INTO Candidates (CandidateName, Gender, DateOfBirth, Email, PhoneNumber, Address,
                                EducationLevel, GPA, YearsOfExperience)
        VALUES (p_CandidateName, p_Gender, p_DateOfBirth, p_Email, p_PhoneNumber, p_Address,
                p_EducationLevel, p_GPA, p_YearsOfExperience);
        SET v_NewCandidateID = LAST_INSERT_ID();
        INSERT INTO CandidateAccounts (CandidateID, Email, PasswordHash) VALUES (v_NewCandidateID, p_Email, p_PasswordHash);
        SET p_Result = CONCAT('SUCCESS: CandidateID = ', v_NewCandidateID);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SaveJob` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SaveJob`(
    IN p_CandidateID INT,
    IN p_PositionID INT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    IF EXISTS (SELECT 1 FROM SavedJobs WHERE CandidateID = p_CandidateID AND PositionID = p_PositionID) THEN
        SET p_Result = 'ERROR: Job already saved.';
    ELSE
        INSERT INTO SavedJobs (CandidateID, PositionID) VALUES (p_CandidateID, p_PositionID);
        SET p_Result = 'SUCCESS: Job saved.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_ScheduleInterview` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ScheduleInterview`(
    IN  p_ApplicationID  INT,
    IN  p_InterviewerID  INT,
    IN  p_Date           DATETIME,
    IN  p_Round          INT,
    IN  p_Type           VARCHAR(20),
    IN  p_Location       VARCHAR(200),
    OUT p_Result         VARCHAR(100)
)
BEGIN
    DECLARE v_AppExists INT DEFAULT 0;
    DECLARE v_NewItvID  INT;
    
    -- Khai báo Exit Handler Rollback khi có lỗi SQL Exception
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_Result = 'ERROR: Transaction failed and rolled back.';
    END;

    SELECT COUNT(*) INTO v_AppExists FROM Applications WHERE ApplicationID = p_ApplicationID AND IsDeleted = FALSE;

    IF v_AppExists = 0 THEN
        SET p_Result = 'ERROR: Application not found.';
    ELSE
        START TRANSACTION;
            INSERT INTO Interviews(ApplicationID, InterviewerID, InterviewDate, RoundNumber, InterviewType, Location)
            VALUES (p_ApplicationID, p_InterviewerID, p_Date, p_Round, p_Type, p_Location);
            SET v_NewItvID = LAST_INSERT_ID();

            IF p_InterviewerID IS NOT NULL THEN
                INSERT INTO InterviewPanel(InterviewID, InterviewerID, Role) VALUES (v_NewItvID, p_InterviewerID, 'Lead');
            END IF;

            UPDATE Applications SET Status = 'Interviewing' WHERE ApplicationID = p_ApplicationID AND IsDeleted = FALSE;
        COMMIT;
        SET p_Result = CONCAT('SUCCESS: InterviewID = ', v_NewItvID);
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SearchCandidatesBySkill` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchCandidatesBySkill`(IN p_SkillName VARCHAR(100))
BEGIN
    SELECT DISTINCT
        c.CandidateID, c.CandidateName, c.Email, c.PhoneNumber,
        c.YearsOfExperience, c.EducationLevel,
        s.SkillName, cs.ProficiencyLevel, cs.YearsUsed
    FROM   Candidates    c
    JOIN   CandidateSkills cs ON c.CandidateID = cs.CandidateID
    JOIN   Skills          s  ON cs.SkillID    = s.SkillID
    WHERE  s.SkillName   LIKE CONCAT('%', p_SkillName, '%')
      AND  c.IsDeleted   = FALSE
      AND  s.IsDeleted   = FALSE
    ORDER BY cs.ProficiencyLevel DESC, c.CandidateName;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SearchJobs` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchJobs`(
    IN p_Keyword VARCHAR(100),       -- tìm trong tên vị trí hoặc tên công ty
    IN p_IndustryName VARCHAR(100),
    IN p_JobType VARCHAR(20),
    IN p_Location VARCHAR(200),
    IN p_MinSalary DECIMAL(15,2),
    IN p_MaxSalary DECIMAL(15,2)
)
BEGIN
    SELECT PositionID, PositionName, EmployerName, IndustryName, JobType, Location, 
           SalaryMin, SalaryMax, ExperienceYears, EducationLevel, Deadline
    FROM View_OpenPositions
    WHERE (p_Keyword IS NULL OR PositionName LIKE CONCAT('%', p_Keyword, '%') OR EmployerName LIKE CONCAT('%', p_Keyword, '%'))
      AND (p_IndustryName IS NULL OR IndustryName LIKE CONCAT('%', p_IndustryName, '%'))
      AND (p_JobType IS NULL OR JobType = p_JobType)
      AND (p_Location IS NULL OR Location LIKE CONCAT('%', p_Location, '%'))
      AND (p_MinSalary IS NULL OR SalaryMax >= p_MinSalary)
      AND (p_MaxSalary IS NULL OR SalaryMin <= p_MaxSalary)
    ORDER BY Deadline IS NULL, Deadline ASC, EmployerName;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SoftDeleteCandidate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SoftDeleteCandidate`(
    IN  p_CandidateID INT,
    OUT p_Result      VARCHAR(100)
)
BEGIN
    DECLARE v_Count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_Count
    FROM   Candidates
    WHERE  CandidateID = p_CandidateID AND IsDeleted = FALSE;

    IF v_Count = 0 THEN
        SET p_Result = 'ERROR: Candidate not found or already deleted.';
    ELSE
        UPDATE Candidates
        SET    IsDeleted = TRUE, DeletedAt = NOW()
        WHERE  CandidateID = p_CandidateID;
        SET p_Result = 'SUCCESS: Candidate and related applications soft deleted.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SoftDeleteEmployer` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SoftDeleteEmployer`(
    IN  p_EmployerID INT,
    OUT p_Result     VARCHAR(100)
)
BEGIN
    DECLARE v_Count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_Count
    FROM   Employers
    WHERE  EmployerID = p_EmployerID AND IsDeleted = FALSE;

    IF v_Count = 0 THEN
        SET p_Result = 'ERROR: Employer not found or already deleted.';
    ELSE
        UPDATE Employers
        SET    IsDeleted = TRUE, DeletedAt = NOW()
        WHERE  EmployerID = p_EmployerID;
        SET p_Result = 'SUCCESS: Employer and related records soft deleted.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SoftDeletePosition` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SoftDeletePosition`(
    IN  p_PositionID INT,
    OUT p_Result     VARCHAR(100)
)
BEGIN
    DECLARE v_Count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_Count
    FROM   JobPositions
    WHERE  PositionID = p_PositionID AND IsDeleted = FALSE;

    IF v_Count = 0 THEN
        SET p_Result = 'ERROR: Position not found or already deleted.';
    ELSE
        UPDATE JobPositions
        SET    IsDeleted = TRUE, DeletedAt = NOW(), Status = 'Closed'
        WHERE  PositionID = p_PositionID;
        SET p_Result = 'SUCCESS: Position soft deleted and closed.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_SubmitApplication` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SubmitApplication`(
    IN  p_CandidateID INT,
    IN  p_PositionID  INT,
    IN  p_CoverLetter TEXT,
    OUT p_Result      VARCHAR(100)
)
BEGIN
    DECLARE v_CandExists INT DEFAULT 0;
    DECLARE v_JobStatus  VARCHAR(20);
    DECLARE v_Deadline   DATE;
    DECLARE v_Duplicate  INT DEFAULT 0;

    -- Kiểm tra ứng viên
    SELECT COUNT(*) INTO v_CandExists FROM Candidates WHERE CandidateID = p_CandidateID AND IsDeleted = FALSE;
    
    -- Lấy thông tin công việc
    SELECT Status, Deadline INTO v_JobStatus, v_Deadline FROM JobPositions WHERE PositionID = p_PositionID AND IsDeleted = FALSE LIMIT 1;

    IF v_CandExists = 0 THEN
        SET p_Result = 'ERROR: Candidate does not exist or deleted.';
    ELSEIF v_JobStatus IS NULL THEN
        SET p_Result = 'ERROR: Position not found.';
    ELSEIF v_JobStatus != 'Open' THEN
        SET p_Result = CONCAT('ERROR: Position is ', v_JobStatus);
    ELSEIF v_Deadline IS NOT NULL AND v_Deadline < CURDATE() THEN
        SET p_Result = 'ERROR: Deadline passed.';
    ELSE
        -- Kiểm tra Unique trên đơn đang Active
        SELECT COUNT(*) INTO v_Duplicate FROM Applications WHERE CandidateID = p_CandidateID AND PositionID = p_PositionID AND IsDeleted = FALSE;
        IF v_Duplicate > 0 THEN
            SET p_Result = 'ERROR: Candidate already applied to this position.';
        ELSE
            INSERT INTO Applications(CandidateID, PositionID, CoverLetter) VALUES (p_CandidateID, p_PositionID, p_CoverLetter);
            SET p_Result = CONCAT('SUCCESS: ApplicationID = ', LAST_INSERT_ID());
        END IF;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UnsaveJob` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UnsaveJob`(
    IN p_CandidateID INT,
    IN p_PositionID INT,
    OUT p_Result VARCHAR(100)
)
BEGIN
    DELETE FROM SavedJobs WHERE CandidateID = p_CandidateID AND PositionID = p_PositionID;
    IF ROW_COUNT() = 0 THEN
        SET p_Result = 'ERROR: Saved job not found.';
    ELSE
        SET p_Result = 'SUCCESS: Job removed from saved.';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateApplicationStatus` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateApplicationStatus`(
    IN p_ApplicationID INT,
    IN p_EmployerID INT,
    IN p_NewStatus VARCHAR(50),
    OUT p_Result VARCHAR(100)
)
BEGIN
    -- Verify application belongs to a job posted by this employer
    IF EXISTS(
        SELECT 1 FROM Applications a 
        JOIN JobPositions jp ON a.PositionID = jp.PositionID 
        WHERE a.ApplicationID = p_ApplicationID AND jp.EmployerID = p_EmployerID
    ) THEN
        UPDATE Applications SET Status = p_NewStatus WHERE ApplicationID = p_ApplicationID;
        SET p_Result = 'Application status updated successfully';
        
        -- The trigger on Applications table should handle ApplicationStatusLog and Notifications
    ELSE
        SET p_Result = 'Error: Application not found or unauthorized';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_UpdateJob` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateJob`(
    IN p_PositionID INT,
    IN p_EmployerID INT,
    IN p_DepartmentID INT,
    IN p_PositionName VARCHAR(255),
    IN p_JobType VARCHAR(50),
    IN p_SalaryMin DECIMAL(10,2),
    IN p_SalaryMax DECIMAL(10,2),
    IN p_ExperienceYears INT,
    IN p_EducationLevel VARCHAR(100),
    IN p_Location VARCHAR(255),
    IN p_Openings INT,
    IN p_MaxRounds INT,
    IN p_Deadline DATE,
    IN p_Status VARCHAR(50),
    OUT p_Result VARCHAR(100)
)
BEGIN
    -- Ensure the job belongs to the given employer
    IF EXISTS(SELECT 1 FROM JobPositions WHERE PositionID = p_PositionID AND EmployerID = p_EmployerID) THEN
        UPDATE JobPositions SET
            DepartmentID = p_DepartmentID,
            PositionName = p_PositionName,
            JobType = p_JobType,
            SalaryMin = p_SalaryMin,
            SalaryMax = p_SalaryMax,
            ExperienceYears = p_ExperienceYears,
            EducationLevel = p_EducationLevel,
            Location = p_Location,
            Openings = p_Openings,
            MaxRounds = p_MaxRounds,
            Deadline = p_Deadline,
            Status = p_Status
        WHERE PositionID = p_PositionID;
        SET p_Result = 'Job position updated successfully';
    ELSE
        SET p_Result = 'Error: Job position not found or unauthorized';
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-07 15:22:59

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `clockhog` DEFAULT CHARACTER SET utf16 COLLATE utf16_unicode_ci ;
USE `clockhog` ;

-- -----------------------------------------------------
-- Table `clockhog`.`APP_USER`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`APP_USER` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `LOGIN` VARCHAR(45) NOT NULL ,
  `PWD` VARCHAR(45) NULL ,
  `FIRST_NAME` VARCHAR(45) NULL ,
  `SECOND_NAME` VARCHAR(45) NULL ,
  `SALUTATION` VARCHAR(45) NULL ,
  `REG_DATE` DATETIME NULL COMMENT 'Auto-filled' ,
  `PRIMARY_EMAIL` VARCHAR(45) NULL ,
  `IS_ACTIVE` VARCHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users' ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `login_UNIQUE` (`LOGIN` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`DICT_CURRENCY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`DICT_CURRENCY` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `CURRENCY_CODE` VARCHAR(3) NULL ,
  `CURRENCY_SYMBOL` VARCHAR(1) NULL ,
  `CURRENCY_NAME` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `currency_code_UNIQUE` (`CURRENCY_CODE` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`COMPANY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`COMPANY` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `NAME` VARCHAR(45) NOT NULL ,
  `URL_EXT` VARCHAR(45) NULL COMMENT 'Part of the url to be added for website address' ,
  `CURRENCY_ID` INT NULL ,
  `PLAN` VARCHAR(16) NULL COMMENT 'Identifier of the obtained plan ' ,
  `PLAN_EXPIRES` DATETIME NULL ,
  `LIMIT_PROJECTS` INT NULL ,
  `LIMIT_USERS` INT NULL ,
  `NOTIFF_DAY` INT NULL DEFAULT 5 COMMENT 'Day of week to send timesheet reminders' ,
  `TIME_UNIT` VARCHAR(1) NULL DEFAULT 'D' COMMENT 'time unit to show spent time. H - hours, D - days' ,
  `REG_DATE` DATETIME NULL COMMENT 'filled automatically' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_CURRENCY_idx` (`CURRENCY_ID` ASC) ,
  CONSTRAINT `FK_COMPANY_CURRENCY`
    FOREIGN KEY (`CURRENCY_ID` )
    REFERENCES `clockhog`.`DICT_CURRENCY` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`USERLINK`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`USERLINK` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NOT NULL ,
  `U_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL ,
  `AMND_USER` INT NULL ,
  `EMAIL` VARCHAR(45) NOT NULL ,
  `ROLE` VARCHAR(4) NOT NULL DEFAULT 'EXEC' COMMENT 'ADM = admin, PM = PM; EXEC = Operator;' ,
  `IS_ACTIVE` VARCHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users (required to keep history timings)' ,
  `JOB_TITLE` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_USER_idx` (`U_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_UL_USER`
    FOREIGN KEY (`U_ID` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_UL_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_UL_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`CUSTOMER`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`CUSTOMER` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `NAME` VARCHAR(45) NULL ,
  `BILLING_ADDRESS` VARCHAR(256) NULL ,
  `CONTACT_PERSON` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_CUSTOMER_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_CUSTOMER_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`PROJECT`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`PROJECT` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `NAME` VARCHAR(45) NULL ,
  `NOTES` VARCHAR(4096) NULL ,
  `BUDGET` DECIMAL(12,2) NULL ,
  `ESTIMATE` BIGINT NULL ,
  `COSTS` DECIMAL(12,2) NULL DEFAULT 0 ,
  `SPENT` BIGINT NULL DEFAULT 0 ,
  `IS_ACTIVE` VARCHAR(1) NULL DEFAULT 'Y' COMMENT 'For not active projects no active tasks are allowed' ,
  `CUSTOMER_ID` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_PROJECTS_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECTS_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `clockhog`.`CUSTOMER` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECTS_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`PROJECT_PHASE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`PROJECT_PHASE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NOT NULL ,
  `PARENT_ID` INT NULL ,
  `NAME` VARCHAR(45) NOT NULL ,
  `NOTES` VARCHAR(4096) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_PARENT_idx` (`PARENT_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_PHASES_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASES_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASES_PARENT`
    FOREIGN KEY (`PARENT_ID` )
    REFERENCES `clockhog`.`PROJECT_PHASE` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASES_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`TASK`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`TASK` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_PHASE_ID` INT NOT NULL ,
  `PROJECT_ID` INT NULL COMMENT 'Non-normalized link to simplify totals calculation; filled automatically' ,
  `NAME` VARCHAR(45) NOT NULL ,
  `NOTES` VARCHAR(4096) NULL ,
  `ESTIMATE` BIGINT NULL ,
  `POSTED` BIGINT NULL DEFAULT 0 ,
  `STATUS` VARCHAR(1) NULL DEFAULT 'N' COMMENT 'A - active; C - completed; N - not started' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_PHASE_idx` (`PROJECT_PHASE_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_TASKS_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASKS_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASKS_PHASE`
    FOREIGN KEY (`PROJECT_PHASE_ID` )
    REFERENCES `clockhog`.`PROJECT_PHASE` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASKS_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`RATE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`RATE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL ,
  `AMND_USER` INT NULL ,
  `USERLINK_ID` INT NULL COMMENT 'If userlink_id and project_id are null - company rate; if userlink_id is null - project rate; if project_id is null - user rate. If project rate is defined - userlink_id cannot be null to avoid ambiguity' ,
  `PROJECT_ID` INT NULL ,
  `RATE` DECIMAL(12,2) NULL ,
  `RATE_TYPE` VARCHAR(1) NULL DEFAULT 'D' COMMENT 'D - daily; W - weekly; H - hourly; M - monthly' ,
  `RATE_DATE_FROM` DATETIME NULL COMMENT 'null for first created rate' ,
  `RATE_DATE_TO` DATETIME NULL COMMENT 'null for active rate of the type' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `INDEX_PERIOD` (`C_ID` ASC, `USERLINK_ID` ASC, `PROJECT_ID` ASC, `RATE_DATE_FROM` ASC, `RATE_DATE_TO` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_RATES_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `clockhog`.`USERLINK` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATES_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATES_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATES_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`ASSIGNMENT`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`ASSIGNMENT` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NULL ,
  `USERLINK_ID` INT NOT NULL ,
  `TASK_ID` INT NULL ,
  `TYPE` VARCHAR(2) NULL DEFAULT 'U' COMMENT 'U for user assignment, PM - for Project Manager assignment (defined for projects only)' ,
  `NOTES` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_TASK_idx` (`TASK_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_ASSIGNMENTS_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENTS_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENTS_TASK`
    FOREIGN KEY (`TASK_ID` )
    REFERENCES `clockhog`.`TASK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENTS_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `clockhog`.`USERLINK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENTS_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`TIMING`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`TIMING` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `TASK_ID` INT NOT NULL ,
  `VALUE` BIGINT NOT NULL ,
  `TIMING_DATE` DATETIME NOT NULL ,
  `USERLINK_ID` INT NOT NULL ,
  `RATE_ID` INT NULL COMMENT 'Can be of non-identified rate (only used when rates are not setup!!!)' ,
  `PROJECT_ID` INT NULL COMMENT 'not-normalized for better search, filled automatically' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_TASK_idx` (`TASK_ID` ASC) ,
  INDEX `FK_RATE_idx` (`RATE_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  INDEX `FK_TIMINGS_PROJECT_idx` (`PROJECT_ID` ASC) ,
  CONSTRAINT `FK_TIMINGS_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMINGS_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `clockhog`.`USERLINK` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMINGS_TASK`
    FOREIGN KEY (`TASK_ID` )
    REFERENCES `clockhog`.`TASK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMINGS_RATE`
    FOREIGN KEY (`RATE_ID` )
    REFERENCES `clockhog`.`RATE` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMINGS_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMINGS_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`NORM`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`NORM` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NULL COMMENT 'Total norm if project is null' ,
  `USERLINK_ID` INT NULL COMMENT 'no userlink will mean total for all users' ,
  `WEEKLY_NORM` BIGINT NULL COMMENT 'No norm if null' ,
  `MONTHLY_NORM` BIGINT NULL COMMENT 'No norm if null' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_NORMS_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORMS_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `clockhog`.`USERLINK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORMS_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `clockhog`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORMS_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`TEMPLATE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`TEMPLATE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `CUSTOMER_ID` INT NOT NULL ,
  `TEMPLATE` BLOB NULL ,
  `TEMPLATE_NAME` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_TEMPLATES_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATES_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `clockhog`.`CUSTOMER` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATES_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `clockhog`.`INVOICE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `clockhog`.`INVOICE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `C_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `INVOICE` BLOB NULL ,
  `INVOICE_DATE` DATETIME NULL ,
  `CUSTOMER_ID` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`C_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_INVOICES_COMPANY`
    FOREIGN KEY (`C_ID` )
    REFERENCES `clockhog`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICES_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `clockhog`.`CUSTOMER` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICES_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `clockhog`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `clockhog` ;
USE `clockhog`;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `APP_USER_BINS` BEFORE INSERT ON APP_USER FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.REG_DATE = SYSDATE()
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `COMPANY_BINS` BEFORE INSERT ON COMPANY FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.REG_DATE = SYSDATE()
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `USER_LINK_BINS` BEFORE INSERT ON USERLINK FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$

USE `clockhog`$$


CREATE TRIGGER `USER_LINK_BUPD` BEFORE UPDATE ON USERLINK FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `PROJECT_BINS` BEFORE INSERT ON PROJECT FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$

USE `clockhog`$$


CREATE TRIGGER `PROJECT_BUPD` BEFORE UPDATE ON PROJECT FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `PROJECT_PHASE_BINS` BEFORE INSERT ON PROJECT_PHASE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM PROJECT P WHERE P.ID = NEW.PROJECT_ID); 
end
$$

USE `clockhog`$$


CREATE TRIGGER `PROJECT_PHASE_BUPD` BEFORE UPDATE ON PROJECT_PHASE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM PROJECT P WHERE P.ID = NEW.PROJECT_ID); 
end
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `TASK_BINS` BEFORE INSERT ON TASK FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.PROJECT_ID = (SELECT MAX(PROJECT_ID) FROM PROJECT_PHASE PH WHERE PH.ID = NEW.PROJECT_PHASE_ID);
SET NEW.C_ID = (SELECT MAX(C_ID) FROM PROJECT_PHASE PH WHERE PH.ID = NEW.PROJECT_PHASE_ID); 
end
$$

USE `clockhog`$$


CREATE TRIGGER `TASK_BUPD` BEFORE UPDATE ON TASK FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
BEGIN
SET NEW.AMND_DATE = SYSDATE();
SET NEW.PROJECT_ID = (SELECT MAX(PROJECT_ID) FROM PROJECT_PHASE PH WHERE PH.ID = NEW.PROJECT_PHASE_ID);
END
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `RATE_BINS` BEFORE INSERT ON RATE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$

USE `clockhog`$$


CREATE TRIGGER `RATE_BUPD` BEFORE UPDATE ON RATE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `ASSIGNMENT_BINS` BEFORE INSERT ON ASSIGNMENT FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM USERLINK UL WHERE UL.ID = NEW.USERLINK_ID); 
end
$$

USE `clockhog`$$


CREATE TRIGGER `ASSIGNMENT_BUPD` BEFORE UPDATE ON ASSIGNMENT FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `TIMING_BINS` BEFORE INSERT ON TIMING FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM USERLINK UL WHERE UL.ID = NEW.USERLINK_ID);
SET NEW.PROJECT_ID = (SELECT MAX(PROJECT_ID) FROM TASK T WHERE T.ID = NEW.TASK_ID);
end
$$

USE `clockhog`$$


CREATE TRIGGER `TIMING_BUPD` BEFORE UPDATE ON TIMING FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `NORM_BINS` BEFORE INSERT ON NORM FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
end$$

USE `clockhog`$$


CREATE TRIGGER `NORM_BUPD` BEFORE UPDATE ON NORM FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `CUSTOMER_BINS` BEFORE INSERT ON CUSTOMER FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE()
$$

USE `clockhog`$$


CREATE TRIGGER `CUSTOMER_BUPD` BEFORE UPDATE ON CUSTOMER FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `TEMPLATE_BINS` BEFORE INSERT ON TEMPLATE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM CUSTOMER C WHERE C.ID = NEW.CUSTOMER_ID);
end;$$

USE `clockhog`$$


CREATE TRIGGER `TEMPLATE_BUPD` BEFORE UPDATE ON TEMPLATE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;

DELIMITER $$
USE `clockhog`$$


CREATE TRIGGER `INVOICE_BINS` BEFORE INSERT ON INVOICE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
begin
SET NEW.AMND_DATE = SYSDATE();
SET NEW.C_ID = (SELECT MAX(C_ID) FROM CUSTOMER C WHERE C.ID = NEW.CUSTOMER_ID);
end
$$

USE `clockhog`$$


CREATE TRIGGER `INVOICE_BUPD` BEFORE UPDATE ON INVOICE FOR EACH ROW
-- Edit trigger body code below this line. Do not edit lines above this one
SET NEW.AMND_DATE = SYSDATE();
$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

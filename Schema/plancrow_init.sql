SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `Plancrow` DEFAULT CHARACTER SET utf16 COLLATE utf16_unicode_ci ;
USE `Plancrow` ;

-- -----------------------------------------------------
-- Table `Plancrow`.`APP_USER`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`APP_USER` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `LOGIN` VARCHAR(45) NOT NULL ,
  `PWD` VARCHAR(45) NULL ,
  `FIRST_NAME` VARCHAR(45) NULL ,
  `SECOND_NAME` VARCHAR(45) NULL ,
  `SALUTATION` VARCHAR(45) NULL ,
  `CREATED_AT` DATETIME NULL COMMENT 'Auto-filled' ,
  `PRIMARY_EMAIL` VARCHAR(45) NULL ,
  `IS_ACTIVE` VARCHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users' ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `login_UNIQUE` (`LOGIN` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`CURRENCY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`CURRENCY` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `CODE` VARCHAR(3) NULL ,
  `SYMBOL` VARCHAR(1) NULL ,
  `NAME` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  UNIQUE INDEX `currency_code_UNIQUE` (`CODE` ASC) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`COMPANY`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`COMPANY` (
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
  `CREATED_AT` DATETIME NULL COMMENT 'filled automatically' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_CURRENCY_idx` (`CURRENCY_ID` ASC) ,
  CONSTRAINT `FK_COMPANY_CURRENCY`
    FOREIGN KEY (`CURRENCY_ID` )
    REFERENCES `Plancrow`.`CURRENCY` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`USERLINK`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`USERLINK` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NOT NULL ,
  `USER_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL ,
  `AMND_USER` INT NULL ,
  `EMAIL` VARCHAR(45) NOT NULL ,
  `ROLE` VARCHAR(4) NOT NULL DEFAULT 'EXEC' COMMENT 'ADM = admin, PM = PM; EXEC = Operator;' ,
  `IS_ACTIVE` VARCHAR(1) NOT NULL DEFAULT 'Y' COMMENT 'Set N for deleted users (required to keep history timings)' ,
  `JOB_TITLE` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_USER_idx` (`USER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_USERLINK_USER`
    FOREIGN KEY (`USER_ID` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_USERLINK_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_USERLINK_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`CUSTOMER`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`CUSTOMER` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `NAME` VARCHAR(45) NULL ,
  `BILLING_ADDRESS` VARCHAR(256) NULL ,
  `CONTACT_PERSON` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_CUSTOMER_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_CUSTOMER_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`PROJECT`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`PROJECT` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NOT NULL ,
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
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_PROJECT_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECT_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `Plancrow`.`CUSTOMER` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PROJECT_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`PROJECT_PHASE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`PROJECT_PHASE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NOT NULL ,
  `PARENT_ID` INT NULL ,
  `NAME` VARCHAR(45) NOT NULL ,
  `NOTES` VARCHAR(4096) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_PARENT_idx` (`PARENT_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_PHASE_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_PARENT`
    FOREIGN KEY (`PARENT_ID` )
    REFERENCES `Plancrow`.`PROJECT_PHASE` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_PHASE_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`TASK`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`TASK` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
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
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_PHASE_idx` (`PROJECT_PHASE_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_TASK_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_PHASE`
    FOREIGN KEY (`PROJECT_PHASE_ID` )
    REFERENCES `Plancrow`.`PROJECT_PHASE` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TASK_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`RATE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`RATE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NOT NULL ,
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
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `INDEX_PERIOD` (`COMPANY_ID` ASC, `USERLINK_ID` ASC, `PROJECT_ID` ASC, `RATE_DATE_FROM` ASC, `RATE_DATE_TO` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_RATE_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `Plancrow`.`USERLINK` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_RATE_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`ASSIGNMENT`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`ASSIGNMENT` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NULL ,
  `USERLINK_ID` INT NOT NULL ,
  `TASK_ID` INT NULL ,
  `TYPE` VARCHAR(2) NULL DEFAULT 'U' COMMENT 'U for user assignment, PM - for Project Manager assignment (defined for projects only)' ,
  `NOTES` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_TASK_idx` (`TASK_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_ASSIGNMENT_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_TASK`
    FOREIGN KEY (`TASK_ID` )
    REFERENCES `Plancrow`.`TASK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `Plancrow`.`USERLINK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_ASSIGNMENT_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`TIMING`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`TIMING` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `TASK_ID` INT NOT NULL ,
  `VALUE` BIGINT NOT NULL ,
  `TIMING_DATE` DATETIME NOT NULL ,
  `USERLINK_ID` INT NOT NULL ,
  `RATE_ID` INT NULL COMMENT 'Can be of non-identified rate (only used when rates are not setup!!!)' ,
  `PROJECT_ID` INT NULL COMMENT 'not-normalized for better search, filled automatically' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_TASK_idx` (`TASK_ID` ASC) ,
  INDEX `FK_RATE_idx` (`RATE_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  INDEX `FK_TIMING_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FT_TIMING_PERIOD` (`PROJECT_ID` ASC, `USERLINK_ID` ASC, `TIMING_DATE` ASC) ,
  CONSTRAINT `FK_TIMING_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `Plancrow`.`USERLINK` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_TASK`
    FOREIGN KEY (`TASK_ID` )
    REFERENCES `Plancrow`.`TASK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_RATE`
    FOREIGN KEY (`RATE_ID` )
    REFERENCES `Plancrow`.`RATE` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TIMING_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`NORM`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`NORM` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NOT NULL ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `PROJECT_ID` INT NULL COMMENT 'Total norm if project is null' ,
  `USERLINK_ID` INT NULL COMMENT 'no userlink will mean total for all users' ,
  `WEEKLY_NORM` BIGINT NULL COMMENT 'No norm if null' ,
  `MONTHLY_NORM` BIGINT NULL COMMENT 'No norm if null' ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_USERLINK_idx` (`USERLINK_ID` ASC) ,
  INDEX `FK_PROJECT_idx` (`PROJECT_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_NORM_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_USERLINK`
    FOREIGN KEY (`USERLINK_ID` )
    REFERENCES `Plancrow`.`USERLINK` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_PROJECT`
    FOREIGN KEY (`PROJECT_ID` )
    REFERENCES `Plancrow`.`PROJECT` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_NORM_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`TEMPLATE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`TEMPLATE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `CUSTOMER_ID` INT NOT NULL ,
  `TEMPLATE` BLOB NULL ,
  `TEMPLATE_NAME` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_TEMPLATE_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATE_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `Plancrow`.`CUSTOMER` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_TEMPLATE_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Plancrow`.`INVOICE`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `Plancrow`.`INVOICE` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `COMPANY_ID` INT NULL COMMENT 'auto-filled' ,
  `AMND_DATE` DATETIME NULL COMMENT 'auto-filled' ,
  `AMND_USER` INT NULL ,
  `INVOICE` BLOB NULL ,
  `CREATED_AT` DATETIME NULL ,
  `CUSTOMER_ID` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `FK_COMPANY_idx` (`COMPANY_ID` ASC) ,
  INDEX `FK_CLIENT_idx` (`CUSTOMER_ID` ASC) ,
  INDEX `FK_AMND_USER_idx` (`AMND_USER` ASC) ,
  CONSTRAINT `FK_INVOICE_COMPANY`
    FOREIGN KEY (`COMPANY_ID` )
    REFERENCES `Plancrow`.`COMPANY` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICE_CLIENT`
    FOREIGN KEY (`CUSTOMER_ID` )
    REFERENCES `Plancrow`.`CUSTOMER` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `FK_INVOICE_AMND_USER`
    FOREIGN KEY (`AMND_USER` )
    REFERENCES `Plancrow`.`APP_USER` (`id` )
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;

USE `Plancrow` ;
USE `Plancrow`;

DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

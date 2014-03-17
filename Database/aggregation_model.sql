SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

DROP SCHEMA IF EXISTS `kpis_db` ;
CREATE SCHEMA IF NOT EXISTS `kpis_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci ;
USE `kpis_db` ;

-- -----------------------------------------------------
-- Table `kpis_db`.`alias_ip_servidores_aplicaciones`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`alias_ip_servidores_aplicaciones` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`alias_ip_servidores_aplicaciones` (
  `ip` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NOT NULL,
  `alias` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `country` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `continent` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `isp` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  PRIMARY KEY (`ip`))
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`operator`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`operator` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`operator` (
  `idoperator` INT(11) NOT NULL AUTO_INCREMENT,
  `alias` VARCHAR(150) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  PRIMARY KEY (`idoperator`))
ENGINE = InnoDB
AUTO_INCREMENT = 1217
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`network_country_codes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`network_country_codes` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`network_country_codes` (
  `mcc` CHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NOT NULL,
  `mnc` CHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NOT NULL,
  `country` CHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `ob` CHAR(150) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `alias` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`mcc`, `mnc`),
  INDEX `fk_network_country_codes_operator1_idx` (`alias` ASC),
  CONSTRAINT `fk_network_country_codes_operator1`
    FOREIGN KEY (`alias`)
    REFERENCES `kpis_db`.`operator` (`idoperator`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`notificaciones_entrantes_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`notificaciones_entrantes_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`notificaciones_entrantes_agr` (
  `fecha` DATETIME NOT NULL COMMENT 'viene de notificaciones_entrantes',
  `ip` VARCHAR(20) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NOT NULL,
  `total` INT(10) UNSIGNED NULL DEFAULT NULL,
  INDEX `fecha` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`notificaciones_entrantes_ncc_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`notificaciones_entrantes_ncc_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`notificaciones_entrantes_ncc_agr` (
  `fecha` DATETIME NOT NULL,
  `mcc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `mnc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `total` INT(10) UNSIGNED NULL DEFAULT NULL)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci
COMMENT = 'quizas añadir IP';


-- -----------------------------------------------------
-- Table `kpis_db`.`notificaciones_entregadas_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`notificaciones_entregadas_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`notificaciones_entregadas_agr` (
  `fecha` DATETIME NOT NULL,
  `mcc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `mnc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `total` INT(10) UNSIGNED NULL DEFAULT NULL COMMENT 'total viene de notificaciones_ws',
  INDEX `fecha` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`notificaciones_enviadas_wu`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`notificaciones_enviadas_wu` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`notificaciones_enviadas_wu` (
  `fecha` DATETIME NOT NULL COMMENT 'Viene de notificaciones_udp',
  `mcc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `mnc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `wakeup` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `total` INT(11) NULL DEFAULT NULL,
  INDEX `fecha` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`peticiones_registros_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`peticiones_registros_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`peticiones_registros_agr` (
  `fecha` DATETIME NOT NULL COMMENT 'viene de peticiones_registros',
  `mcc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `mnc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `total` INT(11) UNSIGNED NULL DEFAULT NULL,
  INDEX `fehca` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`terminales_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`terminales_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`terminales_agr` (
  `fecha` DATETIME NOT NULL,
  `registrados` INT(10) UNSIGNED NULL DEFAULT NULL,
  `activos` INT(10) UNSIGNED NULL DEFAULT NULL,
  `conectados` INT(10) UNSIGNED NULL DEFAULT NULL)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`terminales_con_registros_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`terminales_con_registros_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`terminales_con_registros_agr` (
  `fecha` DATETIME NOT NULL,
  `mcc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `mnc` VARCHAR(3) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `total` INT(11) NULL DEFAULT NULL,
  INDEX `fecha` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


-- -----------------------------------------------------
-- Table `kpis_db`.`tiempo_notificaciones_agr`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `kpis_db`.`tiempo_notificaciones_agr` ;

CREATE TABLE IF NOT EXISTS `kpis_db`.`tiempo_notificaciones_agr` (
  `fecha` DATETIME NOT NULL,
  `max` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `min` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL,
  `avg` VARCHAR(45) CHARACTER SET 'utf8' COLLATE 'utf8_spanish_ci' NULL DEFAULT NULL COMMENT 'La media se puede calcular en periodos mayores ponderando por el número de notificaciones que está en notificaciones_entregadas_agr',
  INDEX `fecha` (`fecha` ASC))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_spanish_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema iEquusDB
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema iEquusDB
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `iEquusDB` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `iEquusDB` ;

-- -----------------------------------------------------
-- Table `iEquusDB`.`Hospitals`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Hospitals` (
  `idHospitals` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `streetName` VARCHAR(255) NOT NULL,
  `streetNumber` VARCHAR(45) NOT NULL,
  `city` VARCHAR(45) NOT NULL,
  `country` VARCHAR(45) NOT NULL,
  `optionalAddressField` VARCHAR(45) NULL DEFAULT NULL,
  `logoPath` VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (`idHospitals`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Veterinarians`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Veterinarians` (
  `idVeterinarian` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phoneNumber` VARCHAR(20) NULL DEFAULT NULL,
  `phoneCountryCode` VARCHAR(10) NULL DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
  `idCedulaProfissional` VARCHAR(40) NOT NULL,
  `Hospitals_idHospitals` INT NULL DEFAULT NULL,
  PRIMARY KEY (`idVeterinarian`),
  INDEX `fk_Veterinarians_Hospitals1_idx` (`Hospitals_idHospitals` ASC) VISIBLE,
  CONSTRAINT `fk_Veterinarians_Hospitals1`
    FOREIGN KEY (`Hospitals_idHospitals`)
    REFERENCES `iEquusDB`.`Hospitals` (`idHospitals`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Horses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Horses` (
  `idHorse` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `profilePicturePath` VARCHAR(255) NULL DEFAULT NULL,
  `birthDate` DATETIME NULL DEFAULT NULL,
  `pictureRightFrontPath` VARCHAR(255) NULL DEFAULT NULL,
  `pictureLeftFrontPath` VARCHAR(255) NULL DEFAULT NULL,
  `pictureRightHindPath` VARCHAR(255) NULL DEFAULT NULL,
  `pictureLeftHindPath` VARCHAR(255) NULL DEFAULT NULL,
  `Veterinarians_idVeterinarian` INT NOT NULL,
  PRIMARY KEY (`idHorse`),
  INDEX `fk_Horses_Veterinarians1_idx` (`Veterinarians_idVeterinarian` ASC) VISIBLE,
  CONSTRAINT `fk_Horses_Veterinarians1`
    FOREIGN KEY (`Veterinarians_idVeterinarian`)
    REFERENCES `iEquusDB`.`Veterinarians` (`idVeterinarian`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Appointments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Appointments` (
  `idAppointment` INT NOT NULL AUTO_INCREMENT,
  `horseId` INT NOT NULL,
  `veterinarianId` INT NOT NULL,
  `lamenessRightFront` INT NULL DEFAULT NULL,
  `lamenessLeftFront` INT NULL DEFAULT NULL,
  `lamenessRightHind` INT NULL DEFAULT NULL,
  `lamenessLeftHind` INT NULL DEFAULT NULL,
  `BPM` INT NULL DEFAULT NULL,
  `muscleTensionFrequency` VARCHAR(255) NULL DEFAULT NULL,
  `muscleTensionStiffness` VARCHAR(255) NULL DEFAULT NULL,
  `muscleTensionR` VARCHAR(255) NULL DEFAULT NULL,
  `CBCpath` VARCHAR(255) NULL DEFAULT NULL,
  `comment` LONGTEXT NULL DEFAULT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ECGtime` INT NULL DEFAULT NULL,
  PRIMARY KEY (`idAppointment`),
  INDEX `fk_Appointments_horses1_idx` (`horseId` ASC) VISIBLE,
  INDEX `fk_Appointments_Veterinarians1_idx` (`veterinarianId` ASC) VISIBLE,
  CONSTRAINT `fk_Appointments_horses1`
    FOREIGN KEY (`horseId`)
    REFERENCES `iEquusDB`.`Horses` (`idHorse`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Appointments_Veterinarians1`
    FOREIGN KEY (`veterinarianId`)
    REFERENCES `iEquusDB`.`Veterinarians` (`idVeterinarian`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Clients`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Clients` (
  `idClient` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NULL DEFAULT NULL,
  `phoneNumber` VARCHAR(20) NULL DEFAULT NULL,
  `phoneCountryCode` VARCHAR(10) NULL DEFAULT NULL,
  PRIMARY KEY (`idClient`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Clients_has_horses`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Clients_has_horses` (
  `Clients_idClient` INT NOT NULL,
  `horses_idHorse` INT NOT NULL,
  `isClientHorseOwner` TINYINT(1) NOT NULL,
  PRIMARY KEY (`Clients_idClient`, `horses_idHorse`),
  INDEX `fk_Clients_has_horses_horses1_idx` (`horses_idHorse` ASC) VISIBLE,
  INDEX `fk_Clients_has_horses_Clients_idx` (`Clients_idClient` ASC) VISIBLE,
  CONSTRAINT `fk_Clients_has_horses_Clients`
    FOREIGN KEY (`Clients_idClient`)
    REFERENCES `iEquusDB`.`Clients` (`idClient`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Clients_has_horses_horses1`
    FOREIGN KEY (`horses_idHorse`)
    REFERENCES `iEquusDB`.`Horses` (`idHorse`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `iEquusDB`.`Measures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `iEquusDB`.`Measures` (
  `idMeasure` INT NOT NULL AUTO_INCREMENT,
  `userBW` INT NULL DEFAULT NULL,
  `algorithmBW` INT NULL DEFAULT NULL,
  `userBCS` INT NULL DEFAULT NULL,
  `algorithmBCS` INT NULL DEFAULT NULL,
  `date` DATETIME NOT NULL,
  `coordinates` JSON NULL DEFAULT NULL,
  `picturePath` VARCHAR(255) NULL DEFAULT NULL,
  `favorite` TINYINT NULL DEFAULT NULL,
  `horseId` INT NOT NULL,
  `veterinarianId` INT NULL DEFAULT NULL,
  `appointmentId` INT NULL DEFAULT NULL,
  PRIMARY KEY (`idMeasure`),
  INDEX `fk_Measures_Horses1_idx` (`horseId` ASC) VISIBLE,
  INDEX `fk_Measures_Veterinarians1_idx` (`veterinarianId` ASC) VISIBLE,
  INDEX `fk_Measures_Appointments1_idx` (`appointmentId` ASC) VISIBLE,
  CONSTRAINT `fk_Measures_Appointments1`
    FOREIGN KEY (`appointmentId`)
    REFERENCES `iEquusDB`.`Appointments` (`idAppointment`),
  CONSTRAINT `fk_Measures_Horses1`
    FOREIGN KEY (`horseId`)
    REFERENCES `iEquusDB`.`Horses` (`idHorse`),
  CONSTRAINT `fk_Measures_Veterinarians1`
    FOREIGN KEY (`veterinarianId`)
    REFERENCES `iEquusDB`.`Veterinarians` (`idVeterinarian`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

USE `iEquusDB`;

DELIMITER $$
USE `iEquusDB`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `iEquusDB`.`set_default_password`
BEFORE INSERT ON `iEquusDB`.`Veterinarians`
FOR EACH ROW
BEGIN
  IF NEW.password IS NULL OR TRIM(NEW.password) = '' THEN
    SET NEW.password = 'password';
  END IF;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

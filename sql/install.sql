-- Δημιουργία ανεξάρτητων πινάκων (Λεξικά και Κατάλογοι)

DROP DATABASE IF EXISTS Ergasiav8;
CREATE DATABASE Ergasiav8;
USE Ergasiav8;

CREATE TABLE `Active_Substance` (
    `substance_name` VARCHAR(150) NOT NULL,
    PRIMARY KEY (`substance_name`)
);

CREATE TABLE `ICD-10_catalog` (
    `ICD-10_code` VARCHAR(20) NOT NULL,
    `description` TEXT NOT NULL, -- Η περιγραφή είναι απαραίτητη
    PRIMARY KEY (`ICD-10_code`)
);

CREATE TABLE `KEN` (
    `KEN_code` VARCHAR(20) NOT NULL,
    `basic_cost` DECIMAL(10,2) NOT NULL,
    `mean_length_of_stay` INT NOT NULL,
    PRIMARY KEY (`KEN_code`)
);

CREATE TABLE `Medical_Procedures_Catalog` (
    `procedure_code` VARCHAR(20) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `category` VARCHAR(100) NOT NULL,
    `duration` INT NOT NULL, -- Διάρκεια σε λεπτά
    `cost` DECIMAL(10,2) NOT NULL,
    `required_room_type` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`procedure_code`),
    CONSTRAINT `chk_category` CHECK (`category` IN ('Surgery', 'Diagnostic', 'Therapeutic')),
    CONSTRAINT `chk_required_room_type` CHECK (`required_room_type` IN ('Operating', 'Procedure'))
);

CREATE TABLE `Medication` (
    `EMA_code` VARCHAR(50) NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`EMA_code`)
);

CREATE TABLE `Room` (
    `room_id` INT NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(50) NOT NULL,
    `image_path` VARCHAR(255),
    `image_description` TEXT,
    PRIMARY KEY (`room_id`),
    CONSTRAINT `chk_room_type` CHECK (`type` IN ('Operating', 'Procedure'))
);

-- Δημιουργία βασικών οντοτήτων (Patient & Staff)
CREATE TABLE `Patient` (
    `AMKA` CHAR(11) NOT NULL,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `father_name` VARCHAR(50),
    `age` INT NOT NULL,
    `sex` VARCHAR(10) NOT NULL,
    `weight` DECIMAL(5,2),
    `height` DECIMAL(5,2),
    `address` VARCHAR(255),
    `phone_number` VARCHAR(15) NOT NULL,
    `email` VARCHAR(100),
    `profession` VARCHAR(100),
    `nationality` VARCHAR(50),
    `relative_contact_info` VARCHAR(255),
    `insurance_carrier` VARCHAR(100),
    PRIMARY KEY (`AMKA`)
);

CREATE TABLE `Staff` (
    `AMKA` CHAR(11) NOT NULL,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    `age` INT NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `phone_number` VARCHAR(15),
    `recruitment_date` DATE NOT NULL,
	`staff_type` VARCHAR(20) NOT NULL,
    `image_path` VARCHAR(255),
    `image_description` TEXT,
    PRIMARY KEY (`AMKA`),
    UNIQUE (`email`), -- Κάθε υπάλληλος έχει μοναδικό email
    CONSTRAINT `chk_staff_type` CHECK (`staff_type` IN ('Doctor', 'Nurse', 'Admin'))
);

CREATE INDEX idx_staff_type_age ON `Staff` (`staff_type`, `age`); -- Q5

-- Εξειδικεύσεις Προσωπικού και Τμήμα
CREATE TABLE `Doctor` (
    `AMKA` CHAR(11) NOT NULL,
    `license_number` VARCHAR(50) NOT NULL,
    `specialty` VARCHAR(100) NOT NULL,
    `rank` VARCHAR(50) NOT NULL,
    `supervisor_AMKA` CHAR(11),
    PRIMARY KEY (`AMKA`),
    UNIQUE (`license_number`),
    FOREIGN KEY (`AMKA`) REFERENCES `Staff`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`supervisor_AMKA`) REFERENCES `Doctor`(`AMKA`),
    CONSTRAINT `chk_supervisor_by_rank` CHECK ((`rank` = 'Intern' AND `supervisor_AMKA` IS NOT NULL) OR (`rank` = 'Director' AND `supervisor_AMKA` IS NULL) OR (`rank` IN ('Consultant_B', 'Consultant_A')))
);

CREATE INDEX idx_specialty ON `Doctor` (`specialty`); -- Q2

CREATE TABLE `Department` (
    `department_id` INT NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(50) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `description` TEXT,
    `bed_count` INT DEFAULT 0,
    `floor` VARCHAR(20) NOT NULL,
    `building` VARCHAR(50) NOT NULL,
    `image_path` VARCHAR(255),
    `image_description` TEXT,
    `director_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`department_id`),
    FOREIGN KEY (`director_AMKA`) REFERENCES `Doctor`(`AMKA`) ON UPDATE CASCADE
);

CREATE TABLE `Nurse` (
    `AMKA` CHAR(11) NOT NULL,
    `rank` VARCHAR(50) NOT NULL,
    `department_id` INT NOT NULL,
    PRIMARY KEY (`AMKA`),
    FOREIGN KEY (`AMKA`) REFERENCES `Staff`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON UPDATE CASCADE,
    CONSTRAINT `chk_nurse_rank` CHECK (`rank` IN ('Assistant', 'Nurse', 'Head'))
);

CREATE TABLE `Admin` (
    `AMKA` CHAR(11) NOT NULL,
    `role` VARCHAR(50) NOT NULL,
    `office` VARCHAR(50),
    `department_id` INT NOT NULL,
    PRIMARY KEY (`AMKA`),
    FOREIGN KEY (`AMKA`) REFERENCES `Staff`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON UPDATE CASCADE
);

-- Πίνακας για την N:M Σχέση Ιατρών - Τμημάτων
CREATE TABLE `Doctor_Department` (
    `doctor_AMKA` CHAR(11) NOT NULL,
    `department_id` INT NOT NULL,
    PRIMARY KEY (`doctor_AMKA`, `department_id`),
    FOREIGN KEY (`doctor_AMKA`) REFERENCES `Doctor`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Πίνακες για Ομάδες και Βάρδιες (Teams & Shifts)
CREATE TABLE `Team` (
    `team_id` INT NOT NULL AUTO_INCREMENT,
    `department_id` INT NOT NULL,
    UNIQUE (`team_id`, `department_id`),
    PRIMARY KEY (`team_id`),
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON UPDATE CASCADE
);

CREATE TABLE `Team_Staff` (
    `team_id` INT NOT NULL,
    `staff_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`team_id`, `staff_AMKA`),
    FOREIGN KEY (`team_id`) REFERENCES `Team`(`team_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`staff_AMKA`) REFERENCES `Staff`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE `Shift` (
    `shift_id` INT NOT NULL AUTO_INCREMENT,
    `date` DATE NOT NULL,
    `shift_type` VARCHAR(50) NOT NULL,
    `team_id` INT NOT NULL,
    `department_id` INT NOT NULL,
    UNIQUE (`date`, `shift_type`, `department_id`), -- kathe bardia monadikh
    PRIMARY KEY (`shift_id`),
    FOREIGN KEY (`team_id`, `department_id`) REFERENCES `Team`(`team_id`, `department_id`) ON UPDATE CASCADE,
    CONSTRAINT `chk_shift_type` CHECK (`shift_type` IN ('Morning', 'Evening', 'Night'))
);

CREATE INDEX idx_shift_date_dept_team ON `Shift` (`date`, `department_id`, `team_id`); -- Q8 Q12

-- Κλίνες και Διαλογή (Triage)
CREATE TABLE `Bed` (
    `bed_number` VARCHAR(20) NOT NULL, -- se periptosi pou exei kai grammata
    `type` VARCHAR(50) NOT NULL,
    `status` VARCHAR(50) NOT NULL,
    `image_path` VARCHAR(255),
    `image_description` TEXT,
    `department_id` INT NOT NULL,
    PRIMARY KEY (`bed_number`),
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_bed_status` CHECK (`status` IN ('Available', 'Occupied', 'Maintenance'))
);

CREATE TABLE `Triage` (
    `triage_id` INT NOT NULL AUTO_INCREMENT,
    `arrival_date` DATETIME NOT NULL,
    `symptoms` TEXT,
    `urgency_level` INT NOT NULL,
    `outcome` VARCHAR(100) NOT NULL,
    `patient_AMKA` CHAR(11) NOT NULL,
    `nurse_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`triage_id`),
    FOREIGN KEY (`patient_AMKA`) REFERENCES `Patient`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`nurse_AMKA`) REFERENCES `Nurse`(`AMKA`) ON UPDATE CASCADE, -- bgalame to ON DELETE SET NULL
    CONSTRAINT `chk_urgency` CHECK (`urgency_level` BETWEEN 1 AND 5)
);

-- Νοσηλεία (Admission)
CREATE TABLE `Admission` (
    `admission_code` INT NOT NULL AUTO_INCREMENT,
    `date_in` DATETIME NOT NULL,
    `date_out` DATETIME DEFAULT NULL, -- NULL όσο νοσηλεύεται
    `total_cost` DECIMAL(10,2) DEFAULT 0.00,
    `patient_AMKA` CHAR(11) NOT NULL,
    `bed_number` VARCHAR(20) NOT NULL,
    `department_id` INT NOT NULL,
    `KEN_code` VARCHAR(20) NOT NULL,
    `diagnosis_in_code` VARCHAR(20) NOT NULL,
    `diagnosis_out_code` VARCHAR(20) DEFAULT NULL,
    UNIQUE (`admission_code`, `patient_AMKA`),
    PRIMARY KEY (`admission_code`),
    FOREIGN KEY (`patient_AMKA`) REFERENCES `Patient`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`bed_number`) REFERENCES `Bed`(`bed_number`) ON UPDATE CASCADE,
    FOREIGN KEY (`department_id`) REFERENCES `Department`(`department_id`) ON UPDATE CASCADE,
    FOREIGN KEY (`KEN_code`) REFERENCES `KEN`(`KEN_code`) ON UPDATE CASCADE,
    FOREIGN KEY (`diagnosis_in_code`) REFERENCES `ICD-10_catalog`(`ICD-10_code`) ON UPDATE CASCADE,
    FOREIGN KEY (`diagnosis_out_code`) REFERENCES `ICD-10_catalog`(`ICD-10_code`) ON UPDATE CASCADE
);

CREATE INDEX idx_admission_patient_dept ON `Admission` (`patient_AMKA`, `department_id`); -- Q3
CREATE INDEX idx_admission_patient_dates ON `Admission` (`patient_AMKA`, `date_in`, `date_out`); -- Q6, Q9
CREATE INDEX idx_admission_diagnosis_date ON `Admission` (`diagnosis_in_code`, `date_in`); -- Q14


-- Αξιολογήσεις, Εξετάσεις και Κλινικά Γεγονότα
CREATE TABLE `Admission_Eval` (
    `admission_eval_code` INT NOT NULL AUTO_INCREMENT,
    `nursing_care_quality` INT NOT NULL,
    `cleanliness` INT NOT NULL,
    `food` INT NOT NULL,
    `overall_experience` INT NOT NULL,
    `admission_code` INT NOT NULL,
    PRIMARY KEY (`admission_eval_code`),
    UNIQUE (`admission_code`), -- Μία αξιολόγηση ανά νοσηλεία
    FOREIGN KEY (`admission_code`) REFERENCES `Admission`(`admission_code`) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `chk_admission_eval_range` CHECK ((`nursing_care_quality` BETWEEN 1 AND 5) AND (`cleanliness` BETWEEN 1 AND 5) AND (`food` BETWEEN 1 AND 5) AND (`overall_experience` BETWEEN 1 AND 5))
);

CREATE TABLE `Doctor_Eval` (
    `doctor_eval_code` INT NOT NULL AUTO_INCREMENT,
    `medical_care_quality` INT NOT NULL,
    `doctor_AMKA` CHAR(11) NOT NULL,
    `admission_code` INT NOT NULL,
    PRIMARY KEY (`doctor_eval_code`),
    UNIQUE (`doctor_AMKA`, `admission_code`), -- Ένας βαθμός ανά γιατρό στη συγκεκριμένη νοσηλεία
    FOREIGN KEY (`doctor_AMKA`) REFERENCES `Doctor`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`admission_code`) REFERENCES `Admission`(`admission_code`) ON UPDATE CASCADE,
    CONSTRAINT `chk_doc_eval` CHECK (`medical_care_quality` BETWEEN 1 AND 5)
);

CREATE INDEX idx_doctor_eval_doctor_admission ON `Doctor_Eval` (`doctor_AMKA`, `admission_code`, `medical_care_quality`); -- Q4

CREATE TABLE `Lab_Test` (
    `test_code` INT NOT NULL AUTO_INCREMENT,
    `type` VARCHAR(100) NOT NULL,
    `test_date` DATETIME NOT NULL,
    `result` VARCHAR(255),
    `cost` DECIMAL(10,2) NOT NULL,
    `admission_code` INT NOT NULL,
    `doctor_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`test_code`),
    FOREIGN KEY (`admission_code`) REFERENCES `Admission`(`admission_code`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`doctor_AMKA`) REFERENCES `Doctor`(`AMKA`) ON UPDATE CASCADE
);

CREATE TABLE `Clinical_Event` (
    `clinical_event_code` INT NOT NULL AUTO_INCREMENT,
    `start_time` DATETIME NOT NULL,
    `procedure_code` VARCHAR(20) NOT NULL,
    `admission_code` INT NOT NULL,
    `room_id` INT NOT NULL,
    `main_surgeon_AMKA` CHAR(11), -- Nullable για μη χειρουργικές πράξεις
    PRIMARY KEY (`clinical_event_code`),
    FOREIGN KEY (`procedure_code`) REFERENCES `Medical_Procedures_Catalog`(`procedure_code`) ON UPDATE CASCADE,
    FOREIGN KEY (`admission_code`) REFERENCES `Admission`(`admission_code`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`room_id`) REFERENCES `Room`(`room_id`) ON UPDATE CASCADE,
    FOREIGN KEY (`main_surgeon_AMKA`) REFERENCES `Doctor`(`AMKA`) ON UPDATE CASCADE
);

CREATE INDEX idx_clinical_event_surgeon_time ON `Clinical_Event` (`main_surgeon_AMKA`, `start_time`); -- Q2, Q5, Q11

-- Βοηθοί Κλινικών Γεγονότων
CREATE TABLE `Clinical_Event_Assistants` (
    `clinical_event_code` INT NOT NULL,
    `staff_AMKA` CHAR(11) NOT NULL,
    PRIMARY KEY (`clinical_event_code`, `staff_AMKA`),
    FOREIGN KEY (`clinical_event_code`) REFERENCES `Clinical_Event`(`clinical_event_code`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`staff_AMKA`) REFERENCES `Staff`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Συνταγογράφηση και Φάρμακα
CREATE TABLE `Prescription` (
    `prescription_id` INT NOT NULL AUTO_INCREMENT,
    `admission_code` INT NOT NULL,
    `doctor_AMKA` CHAR(11) NOT NULL,
    `patient_AMKA` CHAR(11) NOT NULL,
    `EMA_code` VARCHAR(50) NOT NULL,
    `start_date` DATE NOT NULL,
    `end_date` DATE,
    `dosage` VARCHAR(100) NOT NULL,
    `frequency` VARCHAR(100) NOT NULL,
    PRIMARY KEY (`prescription_id`),
    UNIQUE (`doctor_AMKA`, `patient_AMKA`, `EMA_code`, `start_date`),
	FOREIGN KEY (`admission_code`, `patient_AMKA`) REFERENCES `Admission`(`admission_code`, `patient_AMKA`) ON DELETE CASCADE ON UPDATE CASCADE, -- an diagrafei noshleia diagrafontai oi syntagografhseis pou sxetizontai me ayth
    FOREIGN KEY (`doctor_AMKA`) REFERENCES `Doctor`(`AMKA`) ON UPDATE CASCADE,
    FOREIGN KEY (`EMA_code`) REFERENCES `Medication`(`EMA_code`) ON UPDATE CASCADE
);

CREATE INDEX idx_prescription_admission_med ON `Prescription` (`admission_code`, `EMA_code`); -- Q10

-- Ενδιάμεσοι πίνακες για σχέσεις N:M (Αλλεργίες και Περιεχόμενα Φαρμάκων)
CREATE TABLE `Patient_Allergy` (
    `patient_AMKA` CHAR(11) NOT NULL,
    `substance_name` VARCHAR(150) NOT NULL,
    PRIMARY KEY (`patient_AMKA`, `substance_name`),
    FOREIGN KEY (`patient_AMKA`) REFERENCES `Patient`(`AMKA`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`substance_name`) REFERENCES `Active_Substance`(`substance_name`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_patient_allergy_substance ON `Patient_Allergy` (`substance_name`, `patient_AMKA`); -- Q7

CREATE TABLE `Medication_Substance` (
    `EMA_code` VARCHAR(50) NOT NULL,
    `substance_name` VARCHAR(150) NOT NULL,
    PRIMARY KEY (`EMA_code`, `substance_name`),
    FOREIGN KEY (`EMA_code`) REFERENCES `Medication`(`EMA_code`) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`substance_name`) REFERENCES `Active_Substance`(`substance_name`) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX idx_medication_substance_substance ON `Medication_Substance` (`substance_name`, `EMA_code`); -- Q7



DELIMITER //

-- ============================================================
-- 1. Αποφυγή κυκλικής εποπτείας ιατρών - INSERT
-- ============================================================

DROP TRIGGER IF EXISTS `trg_doctor_no_cycle_insert` //

CREATE TRIGGER `trg_doctor_no_cycle_insert`
BEFORE INSERT ON `Doctor`
FOR EACH ROW
BEGIN
    DECLARE `v_supervisor` CHAR(11);

    IF NEW.`supervisor_AMKA` IS NOT NULL THEN
        IF NEW.`supervisor_AMKA` = NEW.`AMKA` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A doctor cannot be supervisor of themselves';
        END IF;

        SET `v_supervisor` = NEW.`supervisor_AMKA`;

        WHILE `v_supervisor` IS NOT NULL DO
            IF `v_supervisor` = NEW.`AMKA` THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cyclic doctor supervision is not allowed';
            END IF;

            SELECT `supervisor_AMKA` INTO `v_supervisor` FROM `Doctor` WHERE `AMKA` = `v_supervisor`;
        END WHILE;
    END IF;
END //


-- ============================================================
-- 1. Αποφυγή κυκλικής εποπτείας ιατρών - UPDATE
-- ============================================================

DROP TRIGGER IF EXISTS `trg_doctor_no_cycle_update` //

CREATE TRIGGER `trg_doctor_no_cycle_update`
BEFORE UPDATE ON `Doctor`
FOR EACH ROW
BEGIN
    DECLARE `v_supervisor` CHAR(11);

    IF NEW.`supervisor_AMKA` IS NOT NULL THEN
        IF NEW.`supervisor_AMKA` = NEW.`AMKA` THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A doctor cannot be supervisor of themselves';
        END IF;

        SET `v_supervisor` = NEW.`supervisor_AMKA`;

        WHILE `v_supervisor` IS NOT NULL DO
            IF `v_supervisor` = NEW.`AMKA` THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cyclic doctor supervision is not allowed';
            END IF;

            SELECT `supervisor_AMKA` INTO `v_supervisor` FROM `Doctor` WHERE `AMKA` = `v_supervisor`;
        END WHILE;
    END IF;
END //


-- ============================================================
-- 2 & 3. Έλεγχος σύνθεσης ομάδας βάρδιας - INSERT
-- ============================================================

DROP TRIGGER IF EXISTS `trg_shift_team_check_insert` //

CREATE TRIGGER `trg_shift_team_check_insert`
BEFORE INSERT ON `Shift`
FOR EACH ROW
BEGIN
    DECLARE `doctor_count` INT DEFAULT 0;
    DECLARE `nurse_count`  INT DEFAULT 0;
    DECLARE `admin_count`  INT DEFAULT 0;
    DECLARE `intern_count` INT DEFAULT 0;
    DECLARE `senior_count` INT DEFAULT 0;

    SELECT COUNT(*) INTO `doctor_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `nurse_count`  FROM `Team_Staff` ts JOIN `Nurse`  n ON n.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `admin_count`  FROM `Team_Staff` ts JOIN `Admin`  a ON a.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `intern_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id` AND d.`rank` = 'Intern';
    SELECT COUNT(*) INTO `senior_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id` AND d.`rank` IN ('Consultant_A', 'Director');

    IF `doctor_count` < 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 3 doctors';
    END IF;

    IF `nurse_count` < 6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 6 nurses';
    END IF;

    IF `admin_count` < 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 2 admins';
    END IF;

    IF `intern_count` > 0 AND `senior_count` = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift with an Intern must also have a Consultant_A or Director';
    END IF;
END //


-- ============================================================
-- 2 & 3. Έλεγχος σύνθεσης ομάδας βάρδιας - UPDATE
-- ============================================================

DROP TRIGGER IF EXISTS `trg_shift_team_check_update` //

CREATE TRIGGER `trg_shift_team_check_update`
BEFORE UPDATE ON `Shift`
FOR EACH ROW
BEGIN
    DECLARE `doctor_count` INT DEFAULT 0;
    DECLARE `nurse_count`  INT DEFAULT 0;
    DECLARE `admin_count`  INT DEFAULT 0;
    DECLARE `intern_count` INT DEFAULT 0;
    DECLARE `senior_count` INT DEFAULT 0;

    SELECT COUNT(*) INTO `doctor_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `nurse_count`  FROM `Team_Staff` ts JOIN `Nurse`  n ON n.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `admin_count`  FROM `Team_Staff` ts JOIN `Admin`  a ON a.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id`;
    SELECT COUNT(*) INTO `intern_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id` AND d.`rank` = 'Intern';
    SELECT COUNT(*) INTO `senior_count` FROM `Team_Staff` ts JOIN `Doctor` d ON d.`AMKA` = ts.`staff_AMKA` WHERE ts.`team_id` = NEW.`team_id` AND d.`rank` IN ('Consultant_A', 'Director');

    IF `doctor_count` < 3 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 3 doctors';
    END IF;

    IF `nurse_count` < 6 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 6 nurses';
    END IF;

    IF `admin_count` < 2 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift team must have at least 2 admins';
    END IF;

    IF `intern_count` > 0 AND `senior_count` = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A shift with an Intern must also have a Consultant_A or Director';
    END IF;
END //


-- ============================================================
-- 4, 5, 6. Procedure για περιορισμούς βαρδιών
-- ============================================================

DROP PROCEDURE IF EXISTS `check_shift_limits` //
CREATE PROCEDURE `check_shift_limits`(IN `p_shift_id` INT, IN `p_date` DATE, IN `p_shift_type` VARCHAR(50), IN `p_team_id` INT)
BEGIN
    DECLARE `new_start` DATETIME;
    DECLARE `new_end` DATETIME;

    SET `new_start` = CASE `p_shift_type` WHEN 'Morning' THEN TIMESTAMP(`p_date`, '07:00:00') WHEN 'Evening' THEN TIMESTAMP(`p_date`, '15:00:00') WHEN 'Night' THEN TIMESTAMP(`p_date`, '23:00:00') END;
    SET `new_end` = CASE `p_shift_type` WHEN 'Morning' THEN TIMESTAMP(`p_date`, '15:00:00') WHEN 'Evening' THEN TIMESTAMP(`p_date`, '23:00:00') WHEN 'Night' THEN TIMESTAMP(DATE_ADD(`p_date`, INTERVAL 1 DAY), '07:00:00') END;

    -- 4. Μέγιστος αριθμός βαρδιών ανά μήνα ανά τύπο προσωπικού
    IF EXISTS (
        SELECT 1
        FROM `Team_Staff` `new_ts` JOIN `Staff` `st` ON `st`.`AMKA` = `new_ts`.`staff_AMKA`
        WHERE `new_ts`.`team_id` = `p_team_id`
          AND (
                SELECT COUNT(*)
                FROM `Shift` `s` JOIN `Team_Staff` `old_ts` ON `old_ts`.`team_id` = `s`.`team_id`
                WHERE `old_ts`.`staff_AMKA` = `new_ts`.`staff_AMKA`
                  AND YEAR(`s`.`date`) = YEAR(`p_date`) AND MONTH(`s`.`date`) = MONTH(`p_date`)
                  AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`)
              ) >= CASE `st`.`staff_type` WHEN 'Doctor' THEN 15 WHEN 'Nurse' THEN 20 WHEN 'Admin' THEN 25 END
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Monthly shift limit exceeded for at least one staff member'; END IF;

    -- 5. Ελάχιστη ανάπαυση 8 ωρών μεταξύ δύο βαρδιών
    IF EXISTS (
        SELECT 1
        FROM `Team_Staff` `new_ts`
        JOIN `Team_Staff` `old_ts` ON `old_ts`.`staff_AMKA` = `new_ts`.`staff_AMKA`
        JOIN `Shift` `s` ON `s`.`team_id` = `old_ts`.`team_id`
        WHERE `new_ts`.`team_id` = `p_team_id`
          AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`)
          AND NOT (
                `new_start` >= DATE_ADD(CASE `s`.`shift_type` WHEN 'Morning' THEN TIMESTAMP(`s`.`date`, '15:00:00') WHEN 'Evening' THEN TIMESTAMP(`s`.`date`, '23:00:00') WHEN 'Night' THEN TIMESTAMP(DATE_ADD(`s`.`date`, INTERVAL 1 DAY), '07:00:00') END, INTERVAL 8 HOUR)
                OR
                CASE `s`.`shift_type` WHEN 'Morning' THEN TIMESTAMP(`s`.`date`, '07:00:00') WHEN 'Evening' THEN TIMESTAMP(`s`.`date`, '15:00:00') WHEN 'Night' THEN TIMESTAMP(`s`.`date`, '23:00:00') END >= DATE_ADD(`new_end`, INTERVAL 8 HOUR)
          )
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'At least one staff member has less than 8 hours of rest between shifts'; END IF;

    -- 6. Όχι πάνω από 3 συνεχόμενες νυχτερινές βάρδιες
    IF `p_shift_type` = 'Night' AND EXISTS (
        SELECT 1
        FROM `Team_Staff` `new_ts`
        WHERE `new_ts`.`team_id` = `p_team_id`
          AND (
                (
                    EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 1 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 2 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 3 DAY))
                )
                OR
                (
                    EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 1 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 2 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 1 DAY))
                )
                OR
                (
                    EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_SUB(`p_date`, INTERVAL 1 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 1 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 2 DAY))
                )
                OR
                (
                    EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 1 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 2 DAY))
                    AND EXISTS (SELECT 1 FROM `Shift` `s` JOIN `Team_Staff` `ts` ON `ts`.`team_id` = `s`.`team_id` WHERE `ts`.`staff_AMKA` = `new_ts`.`staff_AMKA` AND (`p_shift_id` IS NULL OR `s`.`shift_id` <> `p_shift_id`) AND `s`.`shift_type` = 'Night' AND `s`.`date` = DATE_ADD(`p_date`, INTERVAL 3 DAY))
                )
          )
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A staff member cannot work more than 3 consecutive night shifts'; END IF;
END //


-- ============================================================
-- 4, 5, 6. Έλεγχος περιορισμών βαρδιών - INSERT
-- ============================================================

DROP TRIGGER IF EXISTS `trg_shift_limits_insert` //

CREATE TRIGGER `trg_shift_limits_insert`
BEFORE INSERT ON `Shift`
FOR EACH ROW
BEGIN
    CALL `check_shift_limits`(NULL, NEW.`date`, NEW.`shift_type`, NEW.`team_id`);
END //


-- ============================================================
-- 4, 5, 6. Έλεγχος περιορισμών βαρδιών - UPDATE
-- ============================================================

DROP TRIGGER IF EXISTS `trg_shift_limits_update` //

CREATE TRIGGER `trg_shift_limits_update`
BEFORE UPDATE ON `Shift`
FOR EACH ROW
BEGIN
    CALL `check_shift_limits`(OLD.`shift_id`, NEW.`date`, NEW.`shift_type`, NEW.`team_id`);
END //


-- 7 & 9. Απαγόρευση νοσηλείας σε μη διαθέσιμη κλίνη + συμφωνία κλίνης και τμήματος - INSERT

DROP TRIGGER IF EXISTS `trg_admission_bed_check_insert` //

CREATE TRIGGER `trg_admission_bed_check_insert`
BEFORE INSERT ON `Admission`
FOR EACH ROW
BEGIN
    DECLARE `v_bed_status` VARCHAR(50);
    DECLARE `v_bed_department_id` INT;

    SELECT `status`, `department_id` INTO `v_bed_status`, `v_bed_department_id` FROM `Bed` WHERE `bed_number` = NEW.`bed_number`;

    IF `v_bed_status` <> 'Available' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission is not allowed: bed is not available'; END IF;

    IF `v_bed_department_id` <> NEW.`department_id` THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission is not allowed: bed does not belong to the selected department'; END IF;
END //


-- 7 & 9. Απαγόρευση νοσηλείας σε μη διαθέσιμη κλίνη + συμφωνία κλίνης και τμήματος - UPDATE

DROP TRIGGER IF EXISTS `trg_admission_bed_check_update` //

CREATE TRIGGER `trg_admission_bed_check_update`
BEFORE UPDATE ON `Admission`
FOR EACH ROW
BEGIN
    DECLARE `v_bed_status` VARCHAR(50);
    DECLARE `v_bed_department_id` INT;

    SELECT `status`, `department_id` INTO `v_bed_status`, `v_bed_department_id` FROM `Bed` WHERE `bed_number` = NEW.`bed_number`;

    IF `v_bed_department_id` <> NEW.`department_id` THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission is not allowed: bed does not belong to the selected department'; END IF;

    IF NEW.`bed_number` <> OLD.`bed_number` AND `v_bed_status` <> 'Available' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission update is not allowed: new bed is not available'; END IF;
END //


-- 8. Αυτόματη αλλαγή κατάστασης κλίνης - INSERT

DROP TRIGGER IF EXISTS `trg_admission_bed_status_insert` //

CREATE TRIGGER `trg_admission_bed_status_insert`
AFTER INSERT ON `Admission`
FOR EACH ROW
BEGIN
    UPDATE `Bed` SET `status` = CASE WHEN NEW.`date_out` IS NULL THEN 'Occupied' ELSE 'Available' END WHERE `bed_number` = NEW.`bed_number`;
END //


-- 8. Αυτόματη αλλαγή κατάστασης κλίνης - UPDATE

DROP TRIGGER IF EXISTS `trg_admission_bed_status_update` //

CREATE TRIGGER `trg_admission_bed_status_update`
AFTER UPDATE ON `Admission`
FOR EACH ROW
BEGIN
    IF NEW.`bed_number` <> OLD.`bed_number` THEN UPDATE `Bed` SET `status` = 'Available' WHERE `bed_number` = OLD.`bed_number`; UPDATE `Bed` SET `status` = CASE WHEN NEW.`date_out` IS NULL THEN 'Occupied' ELSE 'Available' END WHERE `bed_number` = NEW.`bed_number`; END IF;

    IF OLD.`date_out` IS NULL AND NEW.`date_out` IS NOT NULL THEN UPDATE `Bed` SET `status` = 'Available' WHERE `bed_number` = NEW.`bed_number`; END IF;

    IF OLD.`date_out` IS NOT NULL AND NEW.`date_out` IS NULL THEN UPDATE `Bed` SET `status` = 'Occupied' WHERE `bed_number` = NEW.`bed_number`; END IF;
END //


-- 10. Βοηθητική procedure για επανυπολογισμό κόστους νοσηλείας gia ta lab kai clinical events mono epeidh exei update admission

DROP PROCEDURE IF EXISTS `recalc_admission_total_cost` //

CREATE PROCEDURE `recalc_admission_total_cost`(IN `p_admission_code` INT)
BEGIN
    DECLARE `v_total` DECIMAL(10,2) DEFAULT 0.00;

    SELECT (
        -- 1. Βασικό Κόστος KEN
        `k`.`basic_cost` 
        
        -- 2. Έξυπνη Προσαύξηση, αν η μέση διάρκεια είναι 0: 100€ για κάθε μέρα μετά την πρώτη
        + IF(`k`.`mean_length_of_stay` = 0, (GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, `a`.`date_in`, COALESCE(`a`.`date_out`, NOW())) / 24)) - 1) * 100.00,
            
            -- Αλλιώς, αναλογικος υπολογισμός
            GREATEST(0, GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, `a`.`date_in`, COALESCE(`a`.`date_out`, NOW())) / 24)) - `k`.`mean_length_of_stay`) * (`k`.`basic_cost` / NULLIF(`k`.`mean_length_of_stay`, 0)))
          
        -- 3. Κόστος Εργαστηριακών Εξετάσεων (Lab Tests)
        + IFNULL((SELECT SUM(`lt`.`cost`) FROM `Lab_Test` `lt` WHERE `lt`.`admission_code` = `a`.`admission_code`), 0) 
        
        -- 4. Κόστος Ιατρικών Πράξεων/Χειρουργείων (Clinical Events)
        + IFNULL((SELECT SUM(`mpc`.`cost`) FROM `Clinical_Event` `ce` JOIN `Medical_Procedures_Catalog` `mpc` ON `mpc`.`procedure_code` = `ce`.`procedure_code` WHERE `ce`.`admission_code` = `a`.`admission_code`), 0))
    
    INTO `v_total` FROM `Admission` `a` JOIN `KEN` `k` ON `k`.`KEN_code` = `a`.`KEN_code` WHERE `a`.`admission_code` = `p_admission_code`;

    -- Ενημέρωση του πίνακα με το τελικό ποσό
    UPDATE `Admission` SET `total_cost` = IFNULL(`v_total`, 0.00) WHERE `admission_code` = `p_admission_code`;
END //




-- 10. Υπολογισμός κόστους πριν από INSERT σε Admission

DROP TRIGGER IF EXISTS `trg_admission_cost_insert` //

CREATE TRIGGER `trg_admission_cost_insert`
BEFORE INSERT ON `Admission`
FOR EACH ROW
BEGIN
    DECLARE `v_total` DECIMAL(10,2) DEFAULT 0.00;

    SELECT `k`.`basic_cost` + IF(`k`.`mean_length_of_stay` = 0,
            -- Σενάριο 0 μέρες αναμονή: 100€ η έξτρα μέρα
            (GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, NEW.`date_in`, COALESCE(NEW.`date_out`, NOW())) / 24)) - 1) * 100.00,
            
            -- Σενάριο Κανονικής Νοσηλείας
            GREATEST(0, GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, NEW.`date_in`, COALESCE(NEW.`date_out`, NOW())) / 24)) - `k`.`mean_length_of_stay`) * (`k`.`basic_cost` / NULLIF(`k`.`mean_length_of_stay`, 0))
        )
    INTO `v_total` FROM `KEN` `k` WHERE `k`.`KEN_code` = NEW.`KEN_code`;

    SET NEW.`total_cost` = IFNULL(`v_total`, 0.00);
END //


-- 10. Υπολογισμός κόστους πριν από UPDATE σε Admission

DROP TRIGGER IF EXISTS `trg_admission_cost_update` //

CREATE TRIGGER `trg_admission_cost_update`
BEFORE UPDATE ON `Admission`
FOR EACH ROW
BEGIN
    DECLARE `v_total` DECIMAL(10,2) DEFAULT 0.00;

    SELECT `k`.`basic_cost` 
        -- Υπολογισμός Κόστους Ημερών (Με τη νέα λογική για το 0)
        + IF(`k`.`mean_length_of_stay` = 0, (GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, NEW.`date_in`, COALESCE(NEW.`date_out`, NOW())) / 24)) - 1) * 100.00,
            GREATEST(0, GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, NEW.`date_in`, COALESCE(NEW.`date_out`, NOW())) / 24)) - `k`.`mean_length_of_stay`) * (`k`.`basic_cost` / NULLIF(`k`.`mean_length_of_stay`, 0)))
        
        -- Προσθήκη Εξετάσεων
        + IFNULL((SELECT SUM(`lt`.`cost`) FROM `Lab_Test` `lt` WHERE `lt`.`admission_code` = NEW.`admission_code`), 0) 
        
        -- Προσθήκη Πράξεων
        + IFNULL((SELECT SUM(`mpc`.`cost`) FROM `Clinical_Event` `ce` JOIN `Medical_Procedures_Catalog` `mpc` ON `mpc`.`procedure_code` = `ce`.`procedure_code` WHERE `ce`.`admission_code` = NEW.`admission_code`), 0)
    
    INTO `v_total` FROM `KEN` `k` WHERE `k`.`KEN_code` = NEW.`KEN_code`;

    SET NEW.`total_cost` = IFNULL(`v_total`, 0.00);
END //


-- 10. Επανυπολογισμός κόστους όταν αλλάζουν εργαστηριακές εξετάσεις

DROP TRIGGER IF EXISTS `trg_lab_test_cost_insert` //

CREATE TRIGGER `trg_lab_test_cost_insert`
AFTER INSERT ON `Lab_Test`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(NEW.`admission_code`);
END //

DROP TRIGGER IF EXISTS `trg_lab_test_cost_update` //

CREATE TRIGGER `trg_lab_test_cost_update`
AFTER UPDATE ON `Lab_Test`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(NEW.`admission_code`);
    -- An allaksame to admission code ksanaypologizoume kai gia to palio gia na mh xreothei sto palio admission
    IF NEW.`admission_code` <> OLD.`admission_code` THEN CALL `recalc_admission_total_cost`(OLD.`admission_code`); END IF; 
END //

DROP TRIGGER IF EXISTS `trg_lab_test_cost_delete` //

CREATE TRIGGER `trg_lab_test_cost_delete`
AFTER DELETE ON `Lab_Test`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(OLD.`admission_code`);
END //


-- 10. Επανυπολογισμός κόστους όταν αλλάζουν ιατρικές πράξεις / επεμβάσεις

DROP TRIGGER IF EXISTS `trg_clinical_event_cost_insert` //

CREATE TRIGGER `trg_clinical_event_cost_insert`
AFTER INSERT ON `Clinical_Event`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(NEW.`admission_code`);
END //

DROP TRIGGER IF EXISTS `trg_clinical_event_cost_update` //

CREATE TRIGGER `trg_clinical_event_cost_update`
AFTER UPDATE ON `Clinical_Event`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(NEW.`admission_code`);
    -- An allaksame to admission code ksanaypologizoume kai gia to palio gia na mh xreothei sto palio admission
    IF NEW.`admission_code` <> OLD.`admission_code` THEN CALL `recalc_admission_total_cost`(OLD.`admission_code`); END IF;
END //

DROP TRIGGER IF EXISTS `trg_clinical_event_cost_delete` //

CREATE TRIGGER `trg_clinical_event_cost_delete`
AFTER DELETE ON `Clinical_Event`
FOR EACH ROW
BEGIN
    CALL `recalc_admission_total_cost`(OLD.`admission_code`);
END //


-- 11. Απαγόρευση συνταγογράφησης φαρμάκου με δραστική ουσία στην οποία έχει αλλεργία ο ασθενής - INSERT

DROP TRIGGER IF EXISTS `trg_prescription_allergy_insert` //

CREATE TRIGGER `trg_prescription_allergy_insert`
BEFORE INSERT ON `Prescription`
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM `Medication_Substance` `ms` JOIN `Patient_Allergy` `pa` ON `pa`.`substance_name` = `ms`.`substance_name` WHERE `ms`.`EMA_code` = NEW.`EMA_code` AND `pa`.`patient_AMKA` = NEW.`patient_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription is not allowed: patient is allergic to an active substance of this medication'; END IF;
END //


-- 11. Απαγόρευση συνταγογράφησης φαρμάκου με αλλεργική δραστική ουσία - UPDATE

DROP TRIGGER IF EXISTS `trg_prescription_allergy_update` //

CREATE TRIGGER `trg_prescription_allergy_update`
BEFORE UPDATE ON `Prescription`
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM `Medication_Substance` `ms` JOIN `Patient_Allergy` `pa` ON `pa`.`substance_name` = `ms`.`substance_name` WHERE `ms`.`EMA_code` = NEW.`EMA_code` AND `pa`.`patient_AMKA` = NEW.`patient_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription is not allowed: patient is allergic to an active substance of this medication'; END IF;
END //


-- 12. Αξιολόγηση νοσηλείας μόνο μετά από ολοκληρωμένη νοσηλεία - INSERT

DROP TRIGGER IF EXISTS `trg_admission_eval_completed_insert` //

CREATE TRIGGER `trg_admission_eval_completed_insert`
BEFORE INSERT ON `Admission_Eval`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `Admission` `a` WHERE `a`.`admission_code` = NEW.`admission_code` AND `a`.`date_out` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission evaluation is allowed only after discharge'; END IF;
END //


-- 12. Αξιολόγηση νοσηλείας μόνο μετά από ολοκληρωμένη νοσηλεία - UPDATE

DROP TRIGGER IF EXISTS `trg_admission_eval_completed_update` //

CREATE TRIGGER `trg_admission_eval_completed_update`
BEFORE UPDATE ON `Admission_Eval`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `Admission` `a` WHERE `a`.`admission_code` = NEW.`admission_code` AND `a`.`date_out` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Admission evaluation is allowed only after discharge'; END IF;
END //


-- 12 & 13. Αξιολόγηση ιατρού μόνο μετά από ολοκληρωμένη νοσηλεία και μόνο αν ο ιατρός συνταγογράφησε στη νοσηλεία - INSERT

DROP TRIGGER IF EXISTS `trg_doctor_eval_check_insert` //

CREATE TRIGGER `trg_doctor_eval_check_insert`
BEFORE INSERT ON `Doctor_Eval`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `Admission` `a` WHERE `a`.`admission_code` = NEW.`admission_code` AND `a`.`date_out` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor evaluation is allowed only after discharge'; END IF;

    IF NOT EXISTS (SELECT 1 FROM `Prescription` `p` WHERE `p`.`admission_code` = NEW.`admission_code` AND `p`.`doctor_AMKA` = NEW.`doctor_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor evaluation is allowed only for doctors who prescribed during this admission'; END IF;
END //


-- 12 & 13. Αξιολόγηση ιατρού μόνο μετά από ολοκληρωμένη νοσηλεία και μόνο αν ο ιατρός συνταγογράφησε στη νοσηλεία - UPDATE

DROP TRIGGER IF EXISTS `trg_doctor_eval_check_update` //

CREATE TRIGGER `trg_doctor_eval_check_update`
BEFORE UPDATE ON `Doctor_Eval`
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM `Admission` `a` WHERE `a`.`admission_code` = NEW.`admission_code` AND `a`.`date_out` IS NOT NULL) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor evaluation is allowed only after discharge'; END IF;

    IF NOT EXISTS (SELECT 1 FROM `Prescription` `p` WHERE `p`.`admission_code` = NEW.`admission_code` AND `p`.`doctor_AMKA` = NEW.`doctor_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Doctor evaluation is allowed only for doctors who prescribed during this admission'; END IF;
END //


-- 16 & 17. Συμβατότητα τύπου αίθουσας με πράξη + κύριος χειρουργός για Surgery

DROP PROCEDURE IF EXISTS `check_clinical_event_basic_rules` //

CREATE PROCEDURE `check_clinical_event_basic_rules`(IN `p_procedure_code` VARCHAR(20), IN `p_room_id` INT, IN `p_main_surgeon_AMKA` CHAR(11))
BEGIN
    DECLARE `v_category` VARCHAR(100);
    DECLARE `v_required_room_type` VARCHAR(50);
    DECLARE `v_actual_room_type` VARCHAR(50);

    SELECT `category`, `required_room_type` INTO `v_category`, `v_required_room_type` FROM `Medical_Procedures_Catalog` WHERE `procedure_code` = `p_procedure_code`;
    SELECT `type` INTO `v_actual_room_type` FROM `Room` WHERE `room_id` = `p_room_id`;

    IF `v_actual_room_type` <> `v_required_room_type` THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clinical event is not allowed: room type is not compatible with procedure'; END IF;
    IF `v_category` = 'Surgery' AND `p_main_surgeon_AMKA` IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clinical event is not allowed: surgery requires a main surgeon'; END IF;
END //


-- 14. Όχι overlap πράξεων στον ίδιο χώρο

DROP PROCEDURE IF EXISTS `check_clinical_event_room_overlap` //

CREATE PROCEDURE `check_clinical_event_room_overlap`(IN `p_event_code` INT, IN `p_start_time` DATETIME, IN `p_procedure_code` VARCHAR(20), IN `p_room_id` INT)
BEGIN
    DECLARE `v_duration` INT;
    DECLARE `v_end_time` DATETIME;

    SELECT `duration` INTO `v_duration` FROM `Medical_Procedures_Catalog` WHERE `procedure_code` = `p_procedure_code`;
    SET `v_end_time` = DATE_ADD(`p_start_time`, INTERVAL `v_duration` MINUTE);

    IF EXISTS (SELECT 1 FROM `Clinical_Event` `ce` JOIN `Medical_Procedures_Catalog` `mpc` ON `mpc`.`procedure_code` = `ce`.`procedure_code` WHERE `ce`.`room_id` = `p_room_id` AND (`p_event_code` IS NULL OR `ce`.`clinical_event_code` <> `p_event_code`) AND `ce`.`start_time` < `v_end_time` AND DATE_ADD(`ce`.`start_time`, INTERVAL `mpc`.`duration` MINUTE) > `p_start_time`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clinical event is not allowed: another event overlaps in the same room'; END IF; -- tromeros algorithmos gia ton elegxo
END //


-- 15. Όχι overlap συμμετοχής ίδιου ιατρού σε πράξεις

DROP PROCEDURE IF EXISTS `check_doctor_clinical_event_overlap` //

CREATE PROCEDURE `check_doctor_clinical_event_overlap`(IN `p_event_code` INT, IN `p_doctor_AMKA` CHAR(11), IN `p_start_time` DATETIME, IN `p_procedure_code` VARCHAR(20))
BEGIN
    DECLARE `v_duration` INT;
    DECLARE `v_end_time` DATETIME;

    IF `p_doctor_AMKA` IS NOT NULL THEN
        
        -- 1. Υπολογισμός διάρκειας και λήξης του νέου γεγονότος
        SELECT `duration` INTO `v_duration` FROM `Medical_Procedures_Catalog` WHERE `procedure_code` = `p_procedure_code`;
        SET `v_end_time` = DATE_ADD(`p_start_time`, INTERVAL `v_duration` MINUTE);

        -- 2. Έλεγχος για επικαλύψεις (Overlap)
        IF EXISTS (SELECT 1 FROM `Clinical_Event` `ce` JOIN `Medical_Procedures_Catalog` `mpc` ON `mpc`.`procedure_code` = `ce`.`procedure_code`
            WHERE 
                -- Εξαίρεση του ίδιου του γεγονότος (για περιπτώσεις UPDATE)
                (`p_event_code` IS NULL OR `ce`.`clinical_event_code` <> `p_event_code`)
                -- Tromeros algorithmos επικάλυψης χρόνου
                AND `ce`.`start_time` < `v_end_time` AND DATE_ADD(`ce`.`start_time`, INTERVAL `mpc`.`duration` MINUTE) > `p_start_time`
                -- Έλεγχος αν ο γιατρός συμμετέχει με οποιονδήποτε ρόλο
                AND (`ce`.`main_surgeon_AMKA` = `p_doctor_AMKA`  -- Ως κύριος χειρουργός
                    OR EXISTS (                                  -- Ή ως βοηθός
                        SELECT 1 FROM `Clinical_Event_Assistants` `cea` WHERE `cea`.`clinical_event_code` = `ce`.`clinical_event_code` AND `cea`.`staff_AMKA` = `p_doctor_AMKA`))
        ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clinical event is not allowed: doctor participates in another overlapping event'; 
        END IF;

    END IF;
END //


-- Clinical_Event INSERT

DROP TRIGGER IF EXISTS `trg_clinical_event_rules_insert` //

CREATE TRIGGER `trg_clinical_event_rules_insert`
BEFORE INSERT ON `Clinical_Event`
FOR EACH ROW
BEGIN
    CALL `check_clinical_event_basic_rules`(NEW.`procedure_code`, NEW.`room_id`, NEW.`main_surgeon_AMKA`);
    CALL `check_clinical_event_room_overlap`(NULL, NEW.`start_time`, NEW.`procedure_code`, NEW.`room_id`);
    CALL `check_doctor_clinical_event_overlap`(NULL, NEW.`main_surgeon_AMKA`, NEW.`start_time`, NEW.`procedure_code`);
END //


-- Clinical_Event UPDATE
-- Περιλαμβάνει και έλεγχο για τους ήδη υπάρχοντες assistant doctors του event.

DROP TRIGGER IF EXISTS `trg_clinical_event_rules_update` //

CREATE TRIGGER `trg_clinical_event_rules_update`
BEFORE UPDATE ON `Clinical_Event`
FOR EACH ROW
BEGIN
    CALL `check_clinical_event_basic_rules`(NEW.`procedure_code`, NEW.`room_id`, NEW.`main_surgeon_AMKA`);
    CALL `check_clinical_event_room_overlap`(OLD.`clinical_event_code`, NEW.`start_time`, NEW.`procedure_code`, NEW.`room_id`); -- OLD gia na maste safe
    CALL `check_doctor_clinical_event_overlap`(OLD.`clinical_event_code`, NEW.`main_surgeon_AMKA`, NEW.`start_time`, NEW.`procedure_code`);

    -- xreiazetai mono sto update gt otan kanoume insert to Assistants einai keno
    IF EXISTS (SELECT 1 FROM `Clinical_Event_Assistants` `cea` JOIN `Doctor` `d` ON `d`.`AMKA` = `cea`.`staff_AMKA` WHERE `cea`.`clinical_event_code` = OLD.`clinical_event_code` -- OLD gia na maste safe
          AND EXISTS (
            SELECT 1 FROM `Clinical_Event` `ce2` JOIN `Medical_Procedures_Catalog` `mpc2` ON `mpc2`.`procedure_code` = `ce2`.`procedure_code` JOIN `Medical_Procedures_Catalog` `mpc_new` ON `mpc_new`.`procedure_code` = NEW.`procedure_code`
            WHERE `ce2`.`clinical_event_code` <> OLD.`clinical_event_code` -- Όχι η ίδια η πράξη gia update
              -- Tromeros algorithmos gia epikalypsh
              AND `ce2`.`start_time` < DATE_ADD(NEW.`start_time`, INTERVAL `mpc_new`.`duration` MINUTE) AND DATE_ADD(`ce2`.`start_time`, INTERVAL `mpc2`.`duration` MINUTE) > NEW.`start_time`
              -- Είναι ο βοηθός μπλεγμένος στην άλλη πράξη; (Ως χειρουργός ή ως βοηθός)
              AND (`ce2`.`main_surgeon_AMKA` = `cea`.`staff_AMKA` 
                  OR EXISTS (
                      SELECT 1 FROM `Clinical_Event_Assistants` `cea2` WHERE `cea2`.`clinical_event_code` = `ce2`.`clinical_event_code` AND `cea2`.`staff_AMKA` = `cea`.`staff_AMKA`)))
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Clinical event update is not allowed: an assistant doctor participates in another overlapping event'; 
    END IF;
END //


-- Clinical_Event_Assistants INSERT

DROP TRIGGER IF EXISTS `trg_clinical_event_assistant_insert` //

CREATE TRIGGER `trg_clinical_event_assistant_insert`
BEFORE INSERT ON `Clinical_Event_Assistants`
FOR EACH ROW
BEGIN
    DECLARE `v_start_time` DATETIME;
    DECLARE `v_procedure_code` VARCHAR(20);
	
    -- gia to idio event
    IF EXISTS (SELECT 1 FROM `Clinical_Event` `ce` WHERE `ce`.`clinical_event_code` = NEW.`clinical_event_code` AND `ce`.`main_surgeon_AMKA` = NEW.`staff_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Assistant is not allowed: main surgeon cannot also be assistant in the same event'; END IF;

    IF EXISTS (SELECT 1 FROM `Doctor` `d` WHERE `d`.`AMKA` = NEW.`staff_AMKA`) THEN
        SELECT `start_time`, `procedure_code` INTO `v_start_time`, `v_procedure_code` FROM `Clinical_Event` WHERE `clinical_event_code` = NEW.`clinical_event_code`;
        CALL `check_doctor_clinical_event_overlap`(NEW.`clinical_event_code`, NEW.`staff_AMKA`, `v_start_time`, `v_procedure_code`);
    END IF;
END //


-- Clinical_Event_Assistants UPDATE

DROP TRIGGER IF EXISTS `trg_clinical_event_assistant_update` //

CREATE TRIGGER `trg_clinical_event_assistant_update`
BEFORE UPDATE ON `Clinical_Event_Assistants`
FOR EACH ROW
BEGIN
    DECLARE `v_start_time` DATETIME;
    DECLARE `v_procedure_code` VARCHAR(20);

    -- gia to idio event
    IF EXISTS (SELECT 1 FROM `Clinical_Event` `ce` WHERE `ce`.`clinical_event_code` = NEW.`clinical_event_code` AND `ce`.`main_surgeon_AMKA` = NEW.`staff_AMKA`) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Assistant is not allowed: main surgeon cannot also be assistant in the same event'; END IF;

    IF EXISTS (SELECT 1 FROM `Doctor` `d` WHERE `d`.`AMKA` = NEW.`staff_AMKA`) THEN
        SELECT `start_time`, `procedure_code` INTO `v_start_time`, `v_procedure_code` FROM `Clinical_Event` WHERE `clinical_event_code` = NEW.`clinical_event_code`;
        CALL `check_doctor_clinical_event_overlap`(NEW.`clinical_event_code`, NEW.`staff_AMKA`, `v_start_time`, `v_procedure_code`);
    END IF;
END //


DELIMITER ;
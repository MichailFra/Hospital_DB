WITH YearlyAdmissions AS (
    -- Υπολογίζουμε το πλήθος των εισαγωγών ανά κωδικό ICD-10 και ανά έτος
    SELECT 
        a.diagnosis_in_code AS icd_code,
        c.description AS diagnosis_description,
        YEAR(a.date_in) AS admission_year,
        COUNT(a.admission_code) AS total_admissions
    FROM `Admission` a
    JOIN `ICD-10_catalog` c ON a.diagnosis_in_code = c.`ICD-10_code`
    GROUP BY a.diagnosis_in_code, c.description, YEAR(a.date_in)
    -- Φιλτράρουμε ώστε να κρατήσουμε μόνο τα έτη που είχαν τουλάχιστον 5 περιστατικά
    HAVING COUNT(a.admission_code) >= 5
)
-- Συνδέουμε το CTE με τον εαυτό του για να βρούμε τα συνεχόμενα έτη με ίδιο πλήθος
SELECT 
    y1.icd_code AS `ICD-10_Code`,
    y1.diagnosis_description AS `Description`,
    y1.admission_year AS `Year_1`,
    y2.admission_year AS `Year_2`,
    y1.total_admissions AS `Admissions_Count`
FROM YearlyAdmissions y1
JOIN YearlyAdmissions y2 
    ON y1.icd_code = y2.icd_code
   AND y1.total_admissions = y2.total_admissions -- Ίδιος αριθμός εισαγωγών
   AND y2.admission_year = y1.admission_year + 1 -- Δύο συνεχόμενα έτη
ORDER BY 
    y1.icd_code, 
    y1.admission_year;
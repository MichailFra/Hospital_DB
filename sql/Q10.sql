SELECT 
    p1.patient_AMKA,
    p1.admission_code,
    ms1.substance_name AS Active_Substance_1,
    ms2.substance_name AS Active_Substance_2,
    COUNT(*) AS frequency
FROM 
    Prescription p1
JOIN 
    Medication_Substance ms1 ON p1.EMA_code = ms1.EMA_code
JOIN 
    Prescription p2 ON p1.admission_code = p2.admission_code 
                   AND p1.patient_AMKA = p2.patient_AMKA
JOIN 
    Medication_Substance ms2 ON p2.EMA_code = ms2.EMA_code
WHERE 
    -- 1. Εξασφάλιση μοναδικών ζευγών ουσιών (αποφυγή A-B και B-A ή A-A)
    ms1.substance_name < ms2.substance_name
    
    -- 2. Ταυτόχρονη χορήγηση: Επικάλυψη των διαστημάτων start_date - end_date
    -- Αν το end_date είναι NULL, υποθέτουμε μια πολύ μελλοντική ημερομηνία
    AND p1.start_date <= IFNULL(p2.end_date, '9999-12-31')
    AND p2.start_date <= IFNULL(p1.end_date, '9999-12-31')
GROUP BY 
    ms1.substance_name, 
    ms2.substance_name
ORDER BY 
    frequency DESC
LIMIT 3;
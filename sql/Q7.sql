SELECT 
    ac.substance_name,
    COUNT(DISTINCT pa.patient_AMKA) AS allergic_patients_count,
    COUNT(DISTINCT ms.EMA_code) AS medications_count
FROM 
    Active_Substance ac
LEFT JOIN 
    Patient_Allergy pa ON ac.substance_name = pa.substance_name
LEFT JOIN 
    Medication_Substance ms ON ac.substance_name = ms.substance_name
GROUP BY 
    ac.substance_name
ORDER BY 
    allergic_patients_count DESC;
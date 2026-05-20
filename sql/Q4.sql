SELECT 
    de.doctor_AMKA,
    AVG(de.medical_care_quality) AS avg_medical_care_quality,
    AVG(ae.overall_experience) AS avg_overall_experience
FROM Doctor_Eval de
JOIN Admission_Eval ae ON de.admission_code = ae.admission_code
WHERE de.doctor_AMKA = '07247339492'
GROUP BY de.doctor_AMKA;    

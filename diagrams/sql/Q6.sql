    a.admission_code,
    a.date_in,
    a.date_out,
    a.bed_number,
    dep.name AS department_name,
    icd_in.description AS diagnosis_in_desc,
    icd_out.description AS diagnosis_out_desc, -- Θα εμφανίζεται πάντα αφού είναι πλέον INNER JOIN
    a.total_cost,
    (ae.nursing_care_quality + ae.cleanliness + ae.food + ae.overall_experience) / 4.0 AS avg_evaluation
FROM Admission a
JOIN Department dep 
    ON a.department_id = dep.department_id
JOIN `ICD-10_catalog` icd_in 
    ON a.diagnosis_in_code = icd_in.`ICD-10_code`
-- Μετατροπή σε INNER JOIN (λειτουργεί ως φίλτρο ολοκλήρωσης)
JOIN `ICD-10_catalog` icd_out 
    ON a.diagnosis_out_code = icd_out.`ICD-10_code`
-- Διατήρηση LEFT JOIN για να μη χάσουμε νοσηλείες χωρίς κριτική
LEFT JOIN Admission_Eval ae 
    ON a.admission_code = ae.admission_code
WHERE a.patient_AMKA = '00159245014'
ORDER BY a.date_in DESC;

USE Ergasiav8;

SELECT 
    d.name AS Department_Name,
    YEAR(a.date_in) AS Admission_Year,
    a.KEN_code AS KEN_Code,
    p.insurance_carrier AS Insurance_Carrier,
    COUNT(a.admission_code) AS Total_Admissions,
    SUM(k.basic_cost) AS Total_Basic_Cost_KEN,
    SUM(
        GREATEST(0, GREATEST(1, CEILING(TIMESTAMPDIFF(HOUR, a.date_in, COALESCE(a.date_out, NOW())) / 24)) - k.mean_length_of_stay) 
        * (k.basic_cost / NULLIF(k.mean_length_of_stay, 0))
    ) AS Total_Additional_Charge,
    SUM(a.total_cost) AS Total_Revenue
FROM 
    Admission a
JOIN 
    Department d ON a.department_id = d.department_id
JOIN 
    Patient p ON a.patient_AMKA = p.AMKA
JOIN 
    KEN k ON a.KEN_code = k.KEN_code
GROUP BY 
    d.name, 
    YEAR(a.date_in), 
    a.KEN_code, 
    p.insurance_carrier
ORDER BY 
    Department_Name ASC, 
    Admission_Year DESC, 
    KEN_Code ASC, 
    Total_Revenue DESC;
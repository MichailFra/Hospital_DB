WITH YoungDoctorSurgeries AS (
    SELECT 
        s.AMKA, 
        s.first_name, 
        s.last_name, 
        s.age,
        COUNT(ce.clinical_event_code) AS total_surgeries
    FROM Staff s
    JOIN Doctor d ON s.AMKA = d.AMKA
    JOIN Clinical_Event ce ON d.AMKA = ce.main_surgeon_AMKA
    JOIN Medical_Procedures_Catalog mpc ON ce.procedure_code = mpc.procedure_code
    WHERE s.age < 35
      AND mpc.category = 'Surgery'
    GROUP BY 
        s.AMKA, 
        s.first_name, 
        s.last_name, 
        s.age
)
SELECT 
    AMKA, 
    first_name, 
    last_name, 
    age, 
    total_surgeries
FROM YoungDoctorSurgeries
WHERE total_surgeries = (SELECT MAX(total_surgeries) FROM YoungDoctorSurgeries);
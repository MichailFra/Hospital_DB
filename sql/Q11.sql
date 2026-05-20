WITH DoctorSurgeryCounts AS (
    -- Βήμα 1: Υπολογισμός των επεμβάσεων ανά ιατρό για το τρέχον έτος
    SELECT 
        d.AMKA,
        s.first_name,
        s.last_name,
        COUNT(ce.clinical_event_code) AS num_surgeries
    FROM Doctor d
    INNER JOIN Staff s ON d.AMKA = s.AMKA
    -- Χρήση LEFT JOIN για να συμπεριληφθούν και οι ιατροί με 0 επεμβάσεις
    LEFT JOIN (
        Clinical_Event ce
        INNER JOIN Medical_Procedures_Catalog mpc 
            ON ce.procedure_code = mpc.procedure_code 
            AND mpc.category = 'Surgery' -- Περιορισμός μόνο στις χειρουργικές επεμβάσεις
            AND YEAR(ce.start_time) = 2026 -- Φίλτρο για το έτος 2026
    ) ON d.AMKA = ce.main_surgeon_AMKA
    GROUP BY d.AMKA, s.first_name, s.last_name
),
MaxSurgeries AS (
    -- Βήμα 2: Εύρεση του μέγιστου αριθμού επεμβάσεων από έναν μόνο ιατρό
    SELECT MAX(num_surgeries) AS max_count
    FROM DoctorSurgeryCounts
)
-- Βήμα 3: Επιλογή ιατρών που έχουν τουλάχιστον 5 λιγότερες επεμβάσεις από το μέγιστο
SELECT 
    dsc.AMKA,
    dsc.first_name,
    dsc.last_name,
    dsc.num_surgeries
FROM DoctorSurgeryCounts dsc
CROSS JOIN MaxSurgeries ms
WHERE dsc.num_surgeries <= (ms.max_count - 5)
ORDER BY dsc.num_surgeries DESC;
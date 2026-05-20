USE Ergasiav8;

SELECT 
    d.AMKA,
    st.first_name,
    st.last_name,
    
    -- Ένδειξη αν ο ιατρός είχε τουλάχιστον μία εφημερία το τρέχον έτος
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM Team_Staff ts
            JOIN Shift sh ON ts.team_id = sh.team_id
            WHERE ts.staff_AMKA = d.AMKA
              AND YEAR(sh.date) = YEAR(CURDATE())
        ) THEN 'Yes'
        ELSE 'No'
    END AS had_shift_current_year,
    
    -- Πλήθος επεμβάσεων που εκτέλεσε ως κύριος χειρουργός
    (
        SELECT COUNT(*)
        FROM Clinical_Event ce
        JOIN Medical_Procedures_Catalog mpc ON ce.procedure_code = mpc.procedure_code
        WHERE ce.main_surgeon_AMKA = d.AMKA 
          AND mpc.category = 'Surgery'
    ) AS total_surgeries

FROM Doctor d
JOIN Staff st ON d.AMKA = st.AMKA
WHERE d.specialty = 'Παθολόγος';
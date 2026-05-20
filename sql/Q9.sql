WITH YearlyPatientAdmissions AS (
    -- Βήμα 1 & 2: Εύρεση συνολικών ημερών νοσηλείας ανά ασθενή και ανά έτος,
    -- κρατώντας μόνο όσους έχουν > 15 ημέρες συνολικά.
    SELECT 
        a.patient_AMKA,
        p.first_name,
        p.last_name,
        YEAR(a.date_in) AS admission_year,
        SUM(DATEDIFF(IFNULL(a.date_out, CURRENT_DATE), a.date_in)) AS total_days
    FROM Admission a
    JOIN Patient p ON a.patient_AMKA = p.AMKA
    GROUP BY 
        a.patient_AMKA, 
        p.first_name, 
        p.last_name, 
        YEAR(a.date_in)
    HAVING total_days > 15
)
-- Βήμα 3: Επιλογή των ασθενών που μοιράζονται τον ίδιο αριθμό συνολικών ημερών 
-- στο ίδιο έτος με τουλάχιστον έναν ακόμη ασθενή.
SELECT 
    ypa1.patient_AMKA,
    ypa1.first_name,
    ypa1.last_name,
    ypa1.admission_year,
    ypa1.total_days
FROM YearlyPatientAdmissions ypa1
JOIN (
    -- Υποερώτημα που βρίσκει ποιοι συνδυασμοί (έτος, μέρες) εμφανίζονται πάνω από 1 φορά
    SELECT admission_year, total_days
    FROM YearlyPatientAdmissions
    GROUP BY admission_year, total_days
    HAVING COUNT(patient_AMKA) > 1
) ypa2 ON ypa1.admission_year = ypa2.admission_year AND ypa1.total_days = ypa2.total_days
ORDER BY 
    ypa1.admission_year DESC, 
    ypa1.total_days DESC, 
    ypa1.last_name, 
    ypa1.first_name;
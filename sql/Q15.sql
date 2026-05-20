WITH TriageAdmissions AS (
    -- ΒΑΣΙΚΟ ΒΗΜΑ: Ενώνουμε το Triage με τις Εισαγωγές στο παράθυρο των 24 ωρών
    SELECT
        t.triage_id,
        t.urgency_level,
        t.arrival_date,
        a.admission_code,
        a.department_id,
        TIMESTAMPDIFF(MINUTE, t.arrival_date, a.date_in) AS wait_time_minutes
    FROM Triage t
    LEFT JOIN Admission a
        ON t.patient_AMKA = a.patient_AMKA
        AND a.date_in >= t.arrival_date
        AND a.date_in <= DATE_ADD(t.arrival_date, INTERVAL 24 HOUR)
),
LevelAggregates AS (
    -- 1. Υπολογισμός ΑΝΑ ΕΠΙΠΕΔΟ ΕΠΕΙΓΟΝΤΟΣ (Γενικά στατιστικά επιπέδου)
    SELECT
        urgency_level,
        COUNT(triage_id) AS total_level_cases,
        AVG(wait_time_minutes) AS avg_wait_time_level
    FROM TriageAdmissions
    GROUP BY urgency_level
),
DepartmentDistribution AS (
    -- 2. Υπολογισμός ΑΝΑ ΕΠΙΠΕΔΟ ΕΠΕΙΓΟΝΤΟΣ ΚΑΙ ΑΝΑ ΤΜΗΜΑ (Κατανομή παραπομπών)
    SELECT
        ta.urgency_level,
        COALESCE(d.name, 'Χωρίς Εισαγωγή') AS department_name,
        COUNT(ta.triage_id) AS referrals_to_dept
    FROM TriageAdmissions ta
    LEFT JOIN Department d ON ta.department_id = d.department_id
    GROUP BY ta.urgency_level, d.name
)
-- ΤΕΛΙΚΟ ΑΠΟΤΕΛΕΣΜΑ: Συνδυάζουμε τις δύο βαθμίδες πληροφορίας
SELECT
    la.urgency_level AS `Επίπεδο Επείγοντος`,
    la.total_level_cases AS `Συνολικά Περιστατικά Επιπέδου`,
    ROUND(la.avg_wait_time_level, 2) AS `Μέσος Χρόνος Αναμονής Επιπέδου (Λεπτά)`,
    dd.department_name AS `Τμήμα Παραπομπής`,
    dd.referrals_to_dept AS `Πλήθος Παραπομπών στο Τμήμα`,
    -- Το ποσοστό των περιστατικών του επιπέδου που κατέληξαν στο συγκεκριμένο τμήμα
    ROUND((dd.referrals_to_dept * 100.0) / la.total_level_cases, 2) AS `Ποσοστό Εισαγωγών στο Τμήμα (%)`
FROM LevelAggregates la
JOIN DepartmentDistribution dd ON la.urgency_level = dd.urgency_level
ORDER BY 
    la.urgency_level ASC, 
    dd.referrals_to_dept DESC;
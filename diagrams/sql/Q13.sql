WITH RECURSIVE SupervisionHierarchy AS (
    -- ΒΑΣΙΚΟ ΒΗΜΑ (Base Case):
    -- Ξεκινάμε την αλυσίδα για κάθε ιατρό.
    -- Το Επίπεδο 1 είναι η σχέση του αρχικού ιατρού (starting_doctor) με τον άμεσο επόπτη του.
    SELECT 
        d.AMKA AS starting_doctor_AMKA,
        d.AMKA AS current_doctor_AMKA,
        d.rank AS current_doctor_rank,
        d.supervisor_AMKA AS current_supervisor_AMKA,
        1 AS hierarchy_level
    FROM 
        Doctor d
    WHERE 
        d.supervisor_AMKA IS NOT NULL
        -- ΠΡΟΣΘΗΚΗ: Ξεκινάμε ΜΟΝΟ από αυτούς που ΔΕΝ είναι επόπτες κάποιου άλλου (τα "φύλλα" του δέντρου)
        AND d.AMKA NOT IN (
            SELECT DISTINCT supervisor_AMKA 
            FROM Doctor 
            WHERE supervisor_AMKA IS NOT NULL
        )

    UNION ALL

    -- ΑΝΑΔΡΟΜΙΚΟ ΒΗΜΑ (Recursive Step):
    -- Προχωράμε 'ένα βήμα πάνω' στην ιεραρχία.
    -- Ο επόπτης του προηγούμενου βήματος (d_sup) γίνεται τώρα ο υφιστάμενος (current_doctor),
    -- και βρίσκουμε τον δικό του άμεσο επόπτη, αυξάνοντας το επίπεδο (+1).
    SELECT 
        sh.starting_doctor_AMKA,
        d_sup.AMKA AS current_doctor_AMKA,
        d_sup.rank AS current_doctor_rank,
        d_sup.supervisor_AMKA AS current_supervisor_AMKA,
        sh.hierarchy_level + 1 AS hierarchy_level
    FROM 
        SupervisionHierarchy sh
    JOIN 
        Doctor d_sup ON sh.current_supervisor_AMKA = d_sup.AMKA
)

-- ΤΕΛΙΚΟ ΕΡΩΤΗΜΑ (Final Select):
SELECT 
    sh.starting_doctor_AMKA,
    s_cur.first_name AS current_doctor_first_name,
    s_cur.last_name AS current_doctor_last_name,
    sh.current_doctor_rank,
    sh.hierarchy_level,
    sh.current_supervisor_AMKA AS supervisor_AMKA,
    s_sup.first_name AS supervisor_first_name,
    s_sup.last_name AS supervisor_last_name,
    d_sup.rank AS supervisor_rank
FROM 
    SupervisionHierarchy sh
JOIN 
    Staff s_cur ON sh.current_doctor_AMKA = s_cur.AMKA
-- Χρησιμοποιούμε LEFT JOIN για τους επόπτες, επειδή στο τελευταίο βήμα της αλυσίδας 
-- ο "πάνω-πάνω" (π.χ. Διευθυντής) ΔΕΝ έχει δικό του επόπτη (το supervisor_AMKA είναι NULL).
LEFT JOIN 
    Staff s_sup ON sh.current_supervisor_AMKA = s_sup.AMKA
LEFT JOIN 
    Doctor d_sup ON sh.current_supervisor_AMKA = d_sup.AMKA
ORDER BY 
    sh.starting_doctor_AMKA ASC, 
    sh.hierarchy_level ASC;
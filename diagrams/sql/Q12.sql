SELECT 
    dep.name AS Department_Name,
    s.date AS Shift_Date,
    s.shift_type AS Shift_Type,
    st.staff_type AS Staff_Category,
    COALESCE(d.specialty, n.rank, a.role) AS Staff_Subclass,
    COUNT(ts.staff_AMKA) AS Total_Assigned_Staff
FROM Shift s
JOIN Department dep ON s.department_id = dep.department_id
JOIN Team_Staff ts ON s.team_id = ts.team_id
JOIN Staff st ON ts.staff_AMKA = st.AMKA
-- Left joins για να πάρουμε την υποκλάση (ειδικότητα/βαθμίδα/ρόλο) ανάλογα με τον τύπο
LEFT JOIN Doctor d ON st.AMKA = d.AMKA
LEFT JOIN Nurse n ON st.AMKA = n.AMKA
LEFT JOIN Admin a ON st.AMKA = a.AMKA
-- Ορίζουμε τη συγκεκριμένη εβδομάδα (μπορείς να αλλάξεις τις ημερομηνίες)
WHERE s.date BETWEEN '2026-01-01' AND '2026-01-07' 
GROUP BY 
    dep.department_id,
    dep.name,
    s.date,
    s.shift_type,
    st.staff_type,
    Staff_Subclass
ORDER BY 
    dep.name ASC,
    s.date ASC,
    -- Ταξινόμηση των βαρδιών με τη σωστή χρονική σειρά
    FIELD(s.shift_type, 'Morning', 'Evening', 'Night'), 
    st.staff_type ASC,
    Staff_Subclass ASC;
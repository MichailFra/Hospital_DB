SELECT 
    S.AMKA, 
    S.first_name, 
    S.last_name, 
    S.staff_type
FROM Staff S
WHERE S.AMKA NOT IN (
    -- Υποερώτημα: Βρίσκει τα ΑΜΚΑ του προσωπικού που ΕΧΕΙ προγραμματισμένη βάρδια 
    -- τη συγκεκριμένη μέρα στο συγκεκριμένο τμήμα.
    SELECT TS.staff_AMKA
    FROM Team_Staff TS
    JOIN Shift SH ON TS.team_id = SH.team_id
    JOIN Department D ON SH.department_id = D.department_id
    WHERE SH.date = '2026-05-20'       -- Σταθερά: Αντικαταστήστε με την επιθυμητή ημερομηνία
      AND D.name = 'Καρδιολογία'       -- Σταθερά: Αντικαταστήστε με το επιθυμητό όνομα τμήματος
);
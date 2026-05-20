const db = require('../utils/db');

exports.getAvailableStaff = async (req, res) => {
    try {
        // Παίρνουμε τις τιμές που έβαλε ο χρήστης στη φόρμα (αν υπάρχουν)
        const { searchDate, departmentName } = req.query;

        // Φέρνουμε όλα τα τμήματα για να γεμίσουμε το drop-down (select) της φόρμας
        const [departments] = await db.query('SELECT name FROM Department');

        let staffList = [];
        let hasSearched = false;

        
        if (searchDate && departmentName) {
            hasSearched = true;
            
            const query = `
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
            `;
            
            
            const [results] = await db.query(query, [searchDate, departmentName]);
            staffList = results;
        }

        // Στέλνουμε τα δεδομένα στο view
        res.render('availableStaff', { 
            departments: departments,
            staffList: staffList,
            hasSearched: hasSearched,
            searchDate: searchDate || '',
            departmentName: departmentName || ''
        });

    } catch (err) {
        console.error(err);
        res.status(500).send("Σφάλμα κατά την αναζήτηση προσωπικού.");
    }
};
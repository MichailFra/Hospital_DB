const db = require('../utils/db'); 

exports.getDoctorsBySpecialty = async (req, res) => {
    try {
        // Παίρνουμε την επιλεγμένη ειδικότητα από το URL
        const { specialty } = req.query;

        // Φέρνουμε όλες τις μοναδικές ειδικότητες από τη βάση για το drop-down
        const [specialties] = await db.query('SELECT DISTINCT specialty FROM Doctor ORDER BY specialty ASC');

        let doctorsList = [];
        let hasSearched = false;

        // Αν ο χρήστης έκανε αναζήτηση
        if (specialty) {
            hasSearched = true;
            
            const query = `
                SELECT 
                    d.AMKA,
                    st.first_name,
                    st.last_name,
                    CASE 
                        WHEN EXISTS (
                            SELECT 1
                            FROM Team_Staff ts
                            JOIN Shift sh ON ts.team_id = sh.team_id
                            WHERE ts.staff_AMKA = d.AMKA
                              AND YEAR(sh.date) = YEAR(CURDATE())
                        ) THEN 'Ναι'
                        ELSE 'Όχι'
                    END AS had_shift_current_year,
                    (
                        SELECT COUNT(*)
                        FROM Clinical_Event ce
                        JOIN Medical_Procedures_Catalog mpc ON ce.procedure_code = mpc.procedure_code
                        WHERE ce.main_surgeon_AMKA = d.AMKA 
                          AND mpc.category = 'Surgery'
                    ) AS total_surgeries
                FROM Doctor d
                JOIN Staff st ON d.AMKA = st.AMKA
                WHERE d.specialty = ?
            `;
            
            const [results] = await db.query(query, [specialty]);
            doctorsList = results;
        }

        // Στέλνουμε τα δεδομένα στο EJS View
        res.render('doctorsBySpecialty', { 
            specialties: specialties,
            doctorsList: doctorsList,
            hasSearched: hasSearched,
            selectedSpecialty: specialty || ''
        });

    } catch (err) {
        console.error("Σφάλμα στο Q2:", err);
        res.status(500).send("Σφάλμα κατά την αναζήτηση ιατρών ανά ειδικότητα.");
    }
};
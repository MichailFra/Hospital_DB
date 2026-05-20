const db = require('../utils/db');

exports.getDoctorEvaluation = async (req, res) => {
    try {
        // Παίρνουμε το επιλεγμένο ΑΜΚΑ από το URL
        const { doctorAMKA } = req.query;

        // Φέρνουμε όλους τους ιατρούς για να γεμίσουμε το drop-down
        const doctorsQuery = `
            SELECT d.AMKA, s.first_name, s.last_name, d.specialty 
            FROM Doctor d 
            JOIN Staff s ON d.AMKA = s.AMKA 
            ORDER BY s.last_name ASC, s.first_name ASC
        `;
        const [doctors] = await db.query(doctorsQuery);

        let evalResults = [];
        let hasSearched = false;

        // Αν ο χρήστης έκανε αναζήτηση
        if (doctorAMKA) {
            hasSearched = true;
            
            // Το query του Q4 (χωρίς το EXPLAIN/ANALYZE, μόνο το καθαρό SELECT)
            const query = `
                SELECT 
                    de.doctor_AMKA,
                    AVG(de.medical_care_quality) AS avg_medical_care_quality,
                    AVG(ae.overall_experience) AS avg_overall_experience
                FROM Doctor_Eval de
                JOIN Admission_Eval ae ON de.admission_code = ae.admission_code
                WHERE de.doctor_AMKA = '07247339492'
                GROUP BY de.doctor_AMKA;
            `;
            
            const [results] = await db.query(query, '07247339492');
            evalResults = results;
        }

        // Στέλνουμε τα δεδομένα στο View
        res.render('doctorEvaluation', { 
            doctors: doctors,
            evalResults: evalResults,
            hasSearched: hasSearched,
            selectedAMKA: doctorAMKA || ''
        });

    } catch (err) {
        console.error("Σφάλμα στο Q4:", err);
        res.status(500).send("Σφάλμα κατά την άντληση των αξιολογήσεων.");
    }
};
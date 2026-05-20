const db = require('../utils/db');

exports.getFrequentPatients = async (req, res) => {
    try {
        
        const query = `
            SELECT 
                p.AMKA, 
                p.first_name, 
                p.last_name, 
                d.name AS department_name, 
                COUNT(a.admission_code) AS total_admissions_in_department,
                SUM(a.total_cost) AS total_cost_for_department
            FROM 
                Patient p
            JOIN 
                Admission a ON p.AMKA = a.patient_AMKA
            JOIN 
                Department d ON a.department_id = d.department_id
            GROUP BY 
                p.AMKA, 
                p.first_name, 
                p.last_name, 
                d.department_id, 
                d.name
            HAVING 
                COUNT(a.admission_code) > 3;
        `;

        // Εκτέλεση του query
        const [results] = await db.query(query);

        // Στέλνουμε τα δεδομένα στο View
        res.render('frequentPatients', { 
            patientsList: results 
        });

    } catch (err) {
        console.error("Σφάλμα στο Q3:", err);
        res.status(500).send("Σφάλμα κατά την άντληση των δεδομένων συχνών νοσηλειών.");
    }
};
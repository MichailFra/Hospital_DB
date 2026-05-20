const express = require('express');
const app = express();

// Εισαγωγή των αρχείων με τα Routes (Endpoints)

const staffRoutes = require('./routes/staffRoutes');
const financeRoutes = require('./routes/financeRoutes');
const homeRoutes = require('./routes/homeRoutes');
const doctorRoutes = require('./routes/doctorRoutes'); // ΠΡΟΣΘΗΚΗ
const patientRoutes = require('./routes/patientRoutes'); // ΠΡΟΣΘΗΚΗ
const evaluationRoutes = require('./routes/evaluationRoutes');

// Ρύθμιση του EJS ως Templating Engine 
app.set('view engine', 'ejs');
app.set('views', './views'); // Δηλώνουμε ότι οι σελίδες (.ejs) είναι στον φάκελο views

// Middleware για την επεξεργασία δεδομένων από φόρμες (POST Requests)
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Δήλωση του φακέλου public για στατικά αρχεία (π.χ. CSS, φωτογραφίες)
app.use(express.static('public'));

// Σύνδεση των Routes με την εφαρμογή
app.use('/', staffRoutes);
app.use('/', financeRoutes);
app.use('/', homeRoutes);
app.use('/', doctorRoutes); // ΠΡΟΣΘΗΚΗ
app.use('/', patientRoutes);
app.use('/', evaluationRoutes);

// Ρύθμιση της πόρτας (Port) που θα ακούει ο server μας
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`\n======================================================`);
    console.log(`Ο Server ξεκίνησε με επιτυχία!`);
    console.log(`Μπορείς να μπεις εδώ: http://localhost:${PORT}/available-staff`);
    console.log(`======================================================\n`);
});
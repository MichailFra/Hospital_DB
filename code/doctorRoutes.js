const express = require('express');
const router = express.Router();
const doctorController = require('../controllers/doctorController');

// Το endpoint για το Q2 θα είναι: http://localhost:3000/doctors-by-specialty
router.get('/doctors-by-specialty', doctorController.getDoctorsBySpecialty);

module.exports = router;
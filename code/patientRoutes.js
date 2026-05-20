const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

// Το endpoint για το Q3
router.get('/frequent-patients', patientController.getFrequentPatients);

module.exports = router;
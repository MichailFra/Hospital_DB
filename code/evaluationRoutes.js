const express = require('express');
const router = express.Router();
const evaluationController = require('../controllers/evaluationController');

// Το endpoint για το Q4
router.get('/doctor-evaluation', evaluationController.getDoctorEvaluation);

module.exports = router;
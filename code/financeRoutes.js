const express = require('express');
const router = express.Router();
const financeController = require('../controllers/financeController');

// Το endpoint θα είναι: http://localhost:3000/revenue-report
router.get('/revenue-report', financeController.getRevenueReport);

module.exports = router;
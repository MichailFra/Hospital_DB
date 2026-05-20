const express = require('express');
const router = express.Router();
const staffController = require('../controllers/staffController');

// Όταν ο χρήστης μπαίνει στο /available-staff, τρέξε τον controller
router.get('/available-staff', staffController.getAvailableStaff);

module.exports = router;
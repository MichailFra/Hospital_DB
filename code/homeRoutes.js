const express = require('express');
const router = express.Router();
const homeController = require('../controllers/homeController');

// Όταν κάποιος μπαίνει στο "http://localhost:3000/" 
router.get('/', homeController.getHomePage);

module.exports = router;
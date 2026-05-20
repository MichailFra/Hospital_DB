const mysql = require('mysql2/promise');

// Δημιουργία Connection Pool για μέγιστη απόδοση και σταθερότητα
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',            
    password: '', 
    database: 'Ergasiav8',     // Το όνομα της βάσης
    waitForConnections: true,
    connectionLimit: 10,       // Μέγιστος αριθμός ταυτόχρονων συνδέσεων
    queueLimit: 0
});

module.exports = pool;
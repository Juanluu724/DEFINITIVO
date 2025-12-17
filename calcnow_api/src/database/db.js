const mysql = require('mysql2');
require('dotenv').config(); // Cargar variables de entorno

// Crear un pool de conexiones 
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASS || '',
    database: process.env.DB_NAME || 'calcnow_db',
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Exportar versión con promesas para usar con async/await en tus modelos
module.exports = pool.promise();
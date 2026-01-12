const mysql = require('mysql2/promise');
require('dotenv').config();

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

pool.getConnection()
    .then((connection) => {
        connection.release();
        console.log('Conexión a MySQL establecida correctamente.');
    })
    .catch((error) => {
        console.error('No se pudo establecer la conexión a MySQL:', error.message);
    });

module.exports = pool;

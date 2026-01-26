const mongoose = require('mongoose');

/**
 * Establece la conexion con MongoDB usando Mongoose.
 * Sale del proceso si la URI no esta configurada o si falla el intento de conexion.
 */
const conectarMongo = async () => {
    const uri = process.env.MONGODB_URI;

    if (!uri) {
        console.error('MONGODB_URI no esta definido en las variables de entorno');
        process.exit(1);
    }

    try {
        await mongoose.connect(uri, {
            serverSelectionTimeoutMS: 10000
        });
        console.log('MongoDB conectado');
    } catch (error) {
        console.error('Error conectando a MongoDB:', error.message);
        process.exit(1);
    }

    mongoose.connection.on('disconnected', () => {
        console.warn('Conexion con MongoDB perdida');
    });

    mongoose.connection.on('error', (err) => {
        console.error('Error en la conexion de MongoDB:', err.message);
    });

    return mongoose.connection;
};

module.exports = conectarMongo;

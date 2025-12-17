const db = require('../database/db'); 

class AuthModel {
    constructor(email, password) {
        this.email = email;
        this.password = password;
    }

    static async findByCredentials(email, password) {
        const query = "SELECT * FROM usuario WHERE correo_electronico = ? AND contrasena = ?";
        const [rows] = await db.query(query, [email, password]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async findByEmail(email) {
        const query = "SELECT * FROM usuario WHERE correo_electronico = ?";
        const [rows] = await db.query(query, [email]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async create(email, password) {
        const query = "INSERT INTO usuario (correo_electronico, contrasena) VALUES (?, ?)";
        const [result] = await db.query(query, [email, password]);
        return result;
    }

    isValid() {
        return this.email && this.email.includes('@') && this.password.length >= 6;
    }
}

module.exports = AuthModel;

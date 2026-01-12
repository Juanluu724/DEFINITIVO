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
        const baseName = email ? email.split('@')[0] : 'usuario';
        const nombreUsuario = baseName.substring(0, 50);
        const query = `
            INSERT INTO usuario (nombre_usuario, correo_electronico, fecha_registro, contrasena)
            VALUES (?, ?, CURDATE(), ?)
        `;
        const [result] = await db.query(query, [nombreUsuario, email, password]);
        return result;
    }

    isValid() {
        return this.email && this.email.includes('@') && this.password.length >= 6;
    }
}

module.exports = AuthModel;

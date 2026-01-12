const db = require('../database/db'); 

class AuthModel {
    constructor(email, password) {
        this.email = email;
        this.password = password;
    }

    static async findByCredentials(email, password) {
        const query = "SELECT * FROM USUARIO WHERE correo_electronico = ? AND contrasena = ?";
        const [rows] = await db.query(query, [email, password]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async findByEmail(email) {
        const query = "SELECT * FROM USUARIO WHERE correo_electronico = ?";
        const [rows] = await db.query(query, [email]);
        return rows.length > 0 ? rows[0] : null;
    }

    static async create({ nombre_usuario, email, password }) {
        const query = `
            INSERT INTO USUARIO
                (nombre_usuario, correo_electronico, contrasena, fecha_registro, ultimo_acceso, estado_cuenta)
            VALUES (?, ?, ?, CURRENT_DATE(), NOW(), 'activa')
        `;
        const [result] = await db.query(query, [nombre_usuario, email, password]);
        return result;
    }

    static async updateLastAccess(idUsuario) {
        const [result] = await db.query(
            "UPDATE USUARIO SET ultimo_acceso = NOW() WHERE id_usuario = ?",
            [idUsuario]
        );
        return result.affectedRows;
    }

    isValid() {
        return this.email && this.email.includes('@') && this.password.length >= 6;
    }
}

module.exports = AuthModel;

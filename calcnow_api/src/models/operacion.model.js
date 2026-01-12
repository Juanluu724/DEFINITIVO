const db = require('../database/db');

class OperacionModel {
    static async create(tipoOperacion, idUsuario) {
        const query = `
            INSERT INTO OPERACION (tipo_operacion, fecha_hora, id_usuario)
            VALUES (?, NOW(), ?)
        `;
        const [result] = await db.query(query, [tipoOperacion, idUsuario]);
        return result.insertId;
    }
}

module.exports = OperacionModel;

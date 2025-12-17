const db = require('../database/db');

class NominaModel {

    static async create(datos) {
        const sql = `
      INSERT INTO calculo_nomina (
        sueldo_bruto_anual,
        pagas_anuales,
        edad,
        ubicacion_fiscal,
        grupo_profesional,
        grado_discapacidad,
        estado_civil,
        hijos,
        dependientes,
        traslado_trabajo,
        conyuge_rentas_altas,
        cuota_seguridad_social,
        sueldo_neto_mensual,
        id_usuario
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

        const params = [
            datos.sueldo_bruto_anual,
            datos.pagas_anuales,
            datos.edad,
            datos.ubicacion_fiscal,
            datos.grupo_profesional,
            datos.grado_discapacidad,
            datos.estado_civil,
            datos.hijos,
            datos.dependientes,
            datos.traslado_trabajo,
            datos.conyuge_rentas_altas,
            datos.cuota_seguridad_social,
            datos.sueldo_neto_mensual,
            datos.id_usuario
        ];

        const [result] = await db.query(sql, params);
        return result.insertId;
    }

    static async findByUserId(idUsuario) {
        const [rows] = await db.query(
            "SELECT * FROM calculo_nomina WHERE id_usuario = ? ORDER BY id_nomina DESC", [idUsuario]
        );
        return rows;
    }

    static async delete(id) {
        const [result] = await db.query(
            "DELETE FROM calculo_nomina WHERE id_nomina = ?", [id]
        );
        return result.affectedRows;
    }
}

module.exports = NominaModel;
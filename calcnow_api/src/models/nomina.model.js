const db = require('../database/db');

class NominaModel {

    static async create(datos) {
        const sql = `
      INSERT INTO CALCULO_NOMINA (
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

        try {
            const [result] = await db.query(sql, params);
            return result.insertId;
        } catch (error) {
            throw new Error(`Error al guardar la nómina: ${error.message}`);
        }
    }

    static async findByUserId(idUsuario) {
        try {
            const [rows] = await db.query(
                "SELECT * FROM CALCULO_NOMINA WHERE id_usuario = ? ORDER BY id_nomina DESC", [idUsuario]
            );
            return rows;
        } catch (error) {
            throw new Error(`Error al obtener el historial de nómina: ${error.message}`);
        }
    }

    static async delete(id) {
        try {
            const [result] = await db.query(
                "DELETE FROM CALCULO_NOMINA WHERE id_nomina = ?", [id]
            );
            return result.affectedRows;
        } catch (error) {
            throw new Error(`Error al eliminar la nómina: ${error.message}`);
        }
    }
}

module.exports = NominaModel;

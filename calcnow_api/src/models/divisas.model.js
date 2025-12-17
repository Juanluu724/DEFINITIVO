const db = require('../database/db');
const OperacionModel = require('./operacion.model');

class DivisasModel {

    static async guardar({ id_usuario, cantidad, resultado, origen, destino, valor_tasa }) {
        try {
            // 1. Busca ID moneda Origen (Si no existe, la crea)
            let [resOrigen] = await db.query("SELECT id_divisa FROM DIVISA WHERE simbolo = ?", [origen]);
            let idOrigen = resOrigen.length ? resOrigen[0].id_divisa : null;
            if (!idOrigen) {
                const [insertOrigen] = await db.query(
                    "INSERT INTO DIVISA (nombre, simbolo, pais) VALUES (?, ?, 'Auto')",
                    [origen, origen]
                );
                idOrigen = insertOrigen.insertId;
            }

            // 2. Busca ID moneda Destino (Si no existe, la crea)
            let [resDestino] = await db.query("SELECT id_divisa FROM DIVISA WHERE simbolo = ?", [destino]);
            let idDestino = resDestino.length ? resDestino[0].id_divisa : null;
            if (!idDestino) {
                const [insertDestino] = await db.query(
                    "INSERT INTO DIVISA (nombre, simbolo, pais) VALUES (?, ?, 'Auto')",
                    [destino, destino]
                );
                idDestino = insertDestino.insertId;
            }

            // 3. Busca o actualiza la tasa de cambio
            const tasaValor = Number.isFinite(valor_tasa) ? valor_tasa : 1;
            let [resTasa] = await db.query(
                "SELECT id_tasa_cambio FROM TASA_CAMBIO WHERE id_divisa_origen = ? AND id_divisa_destino = ?",
                [idOrigen, idDestino]
            );
            let idTasa;
            if (resTasa.length) {
                idTasa = resTasa[0].id_tasa_cambio;
                await db.query(
                    "UPDATE TASA_CAMBIO SET valor_tasa = ?, fecha_actualizacion = NOW() WHERE id_tasa_cambio = ?",
                    [tasaValor, idTasa]
                );
            } else {
                const [insertTasa] = await db.query(
                    "INSERT INTO TASA_CAMBIO (valor_tasa, fecha_actualizacion, id_divisa_origen, id_divisa_destino) VALUES (?, NOW(), ?, ?)",
                    [tasaValor, idOrigen, idDestino]
                );
                idTasa = insertTasa.insertId;
            }

            // 4. Guardamos la operación asociada al usuario (si se envía)
            let idOperacion = null;
            if (id_usuario) {
                idOperacion = await OperacionModel.create('DIVISA', id_usuario);
            }

            // 5. Finalmente guardamos el cálculo de divisa
            const query = `
                INSERT INTO CALCULO_DIVISA
                (datos_entrada, resultado, id_divisa_origen, id_divisa_destino, id_tasa_cambio)
                VALUES (?, ?, ?, ?, ?)
            `;
            const [result] = await db.query(query, [cantidad, resultado, idOrigen, idDestino, idTasa]);

            return { id_calculo_divisa: result.insertId, id_tasa_cambio: idTasa, id_operacion: idOperacion };
        } catch (error) {
            console.error("Error SQL en DivisasModel:", error);
            throw error;
        }
    }
}

module.exports = DivisasModel;

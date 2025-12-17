const db = require('../database/db'); 

class DivisasModel {

    static async guardar({ id_usuario, cantidad, resultado, origen, destino }) {
        try {
            // 1. Busca ID moneda Origen (Si no existe, la crea)
            let [resOrigen] = await db.query("SELECT id_divisa FROM DIVISA WHERE simbolo = ?", [origen]);
            let idOrigen = resOrigen.length ? resOrigen[0].id_divisa : (await db.query("INSERT INTO DIVISA (nombre, simbolo, pais) VALUES (?, ?, 'Auto')", [origen, origen]))[0].insertId;

            // 2. Busca ID moneda Destino (Si no existe, la crea)
            let [resDestino] = await db.query("SELECT id_divisa FROM DIVISA WHERE simbolo = ?", [destino]);
            let idDestino = resDestino.length ? resDestino[0].id_divisa : (await db.query("INSERT INTO DIVISA (nombre, simbolo, pais) VALUES (?, ?, 'Auto')", [destino, destino]))[0].insertId;

            // 3. Busca ID Tasa (Si no existe, crea una genérica)
            let [resTasa] = await db.query("SELECT id_tasa_cambio FROM TASA_CAMBIO WHERE id_divisa_origen = ? AND id_divisa_destino = ?", [idOrigen, idDestino]);
            let idTasa = resTasa.length ? resTasa[0].id_tasa_cambio : (await db.query("INSERT INTO TASA_CAMBIO (valor_tasa, fecha_actualizacion, id_divisa_origen, id_divisa_destino) VALUES (1, NOW(), ?, ?)", [idOrigen, idDestino]))[0].insertId;

            // 4. FINALMENTE GUARDAMOS LA OPERACIÓN
            const query = `
                INSERT INTO CALCULO_DIVISA 
                (datos_entrada, resultado, id_divisa_origen, id_divisa_destino, id_tasa_cambio, id_usuario)
                VALUES (?, ?, ?, ?, ?, ?)
            `;
            const [result] = await db.query(query, [cantidad, resultado, idOrigen, idDestino, idTasa, id_usuario]);
            
            return result.insertId;
        } catch (error) {
            console.error("Error SQL en DivisasModel:", error);
            throw error;
        }
    }
}

module.exports = DivisasModel;
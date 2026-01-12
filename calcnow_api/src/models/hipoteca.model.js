const db = require('../database/db');

class HipotecaModel {
    constructor(monto, interes, anios) {
        this.monto = parseFloat(monto);
        this.interes = parseFloat(interes);
        this.anios = parseInt(anios);
    }

    calcular() {
        const r = (this.interes / 100) / 12;
        const n = this.anios * 12;
        let cuota = 0;
        if (r === 0) cuota = this.monto / n;
        else cuota = (this.monto * r) / (1 - Math.pow(1 + r, -n));
        
        const total = cuota * n;
        return {
            cuota_mensual: cuota.toFixed(2),
            total_pagado: total.toFixed(2),
            intereses: (total - this.monto).toFixed(2)
        };
    }

    // --- SQL Methods ---
    static async create({ id_usuario, monto, interes, anios, cuota, total, coste_aportado = null, localizacion = null, estado_inmueble = null, id_simulacion = null }) {
        const query = `
            INSERT INTO SIMULACION_HIPOTECA
            (id_simulacion, precio_inmueble, coste_aportado, porcentaje_interes, plazo_anios, localizacion, estado_inmueble, cuota_mensual, precio_final, id_usuario)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `;
        const params = [id_simulacion || null, monto, coste_aportado, interes, anios, localizacion, estado_inmueble, cuota, total, id_usuario];
        const [result] = await db.query(query, params);
        return result.insertId;
    }

    static async findByUserId(id) {
        const [rows] = await db.query("SELECT * FROM SIMULACION_HIPOTECA WHERE id_usuario = ? ORDER BY id_hipoteca DESC", [id]);
        return rows;
    }

    static async delete(id) {
        const [result] = await db.query("DELETE FROM SIMULACION_HIPOTECA WHERE id_hipoteca = ?", [id]);
        return result.affectedRows;
    }
}

module.exports = HipotecaModel;
const db = require('../database/db');

class BiModel {
    static async kpisGlobales() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_kpis_globales");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_kpis_globales: ${error.message}`);
        }
    }

    static async popularidadModulos() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_popularidad_modulos");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_popularidad_modulos: ${error.message}`);
        }
    }

    static async hipotecasPorProvincia() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_hipotecas_por_provincia");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_hipotecas_por_provincia: ${error.message}`);
        }
    }

    static async nominasPorProvincia() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_nominas_por_provincia");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_nominas_por_provincia: ${error.message}`);
        }
    }

    static async divisasPorMoneda() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_divisas_por_moneda");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_divisas_por_moneda: ${error.message}`);
        }
    }

    static async topHipotecaProvincia() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_top_hipoteca_provincia");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_top_hipoteca_provincia: ${error.message}`);
        }
    }

    static async topDivisa() {
        try {
            const [rows] = await db.query("SELECT * FROM vw_top_divisa");
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_top_divisa: ${error.message}`);
        }
    }
}

module.exports = BiModel;

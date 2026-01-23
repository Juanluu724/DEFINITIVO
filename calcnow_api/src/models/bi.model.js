const db = require('../database/db');

const DATE_COLUMNS = ['fecha', 'fecha_registro', 'fecha_creacion', 'created_at', 'updated_at'];
const dateColumnCache = new Map();

async function resolveDateColumn(viewName) {
    if (dateColumnCache.has(viewName)) {
        return dateColumnCache.get(viewName);
    }
    try {
        const [columns] = await db.query(`SHOW COLUMNS FROM \`${viewName}\``);
        const names = columns.map((c) => String(c.Field).toLowerCase());
        const found = DATE_COLUMNS.find((c) => names.includes(c)) || null;
        dateColumnCache.set(viewName, found);
        return found;
    } catch (error) {
        dateColumnCache.set(viewName, null);
        return null;
    }
}

async function queryView(viewName, filters = {}) {
    const { from, to } = filters || {};
    if (!from && !to) {
        const [rows] = await db.query(`SELECT * FROM \`${viewName}\``);
        return rows;
    }
    const dateColumn = await resolveDateColumn(viewName);
    if (!dateColumn) {
        const [rows] = await db.query(`SELECT * FROM \`${viewName}\``);
        return rows;
    }
    const clauses = [];
    const params = [];
    if (from) {
        clauses.push(`\`${dateColumn}\` >= ?`);
        params.push(from);
    }
    if (to) {
        clauses.push(`\`${dateColumn}\` <= ?`);
        params.push(to);
    }
    const where = clauses.length ? ` WHERE ${clauses.join(' AND ')}` : '';
    const [rows] = await db.query(`SELECT * FROM \`${viewName}\`${where}`, params);
    return rows;
}

class BiModel {
    static async kpisGlobales(filters) {
        try {
            const rows = await queryView('vw_kpis_globales', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_kpis_globales: ${error.message}`);
        }
    }

    static async popularidadModulos(filters) {
        try {
            const rows = await queryView('vw_popularidad_modulos', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_popularidad_modulos: ${error.message}`);
        }
    }

    static async hipotecasPorProvincia(filters) {
        try {
            const rows = await queryView('vw_hipotecas_por_provincia', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_hipotecas_por_provincia: ${error.message}`);
        }
    }

    static async nominasPorProvincia(filters) {
        try {
            const rows = await queryView('vw_nominas_por_provincia', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_nominas_por_provincia: ${error.message}`);
        }
    }

    static async divisasPorMoneda(filters) {
        try {
            const rows = await queryView('vw_divisas_por_moneda', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_divisas_por_moneda: ${error.message}`);
        }
    }

    static async topHipotecaProvincia(filters) {
        try {
            const rows = await queryView('vw_top_hipoteca_provincia', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_top_hipoteca_provincia: ${error.message}`);
        }
    }

    static async topDivisa(filters) {
        try {
            const rows = await queryView('vw_top_divisa', filters);
            return rows;
        } catch (error) {
            throw new Error(`Error al leer vw_top_divisa: ${error.message}`);
        }
    }
}

module.exports = BiModel;

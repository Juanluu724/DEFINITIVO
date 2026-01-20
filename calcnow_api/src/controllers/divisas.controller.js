const axios = require('axios');
const divisasService = require('../services/divisas.service');

const CACHE_TTL_MS = 10 * 60 * 1000;
const XE_API_BASE_URL = (process.env.XE_API_BASE_URL || 'https://xecdapi.xe.com/v1').replace(/\/+$/, '');
const XE_API_ID = process.env.XE_API_ID;
const XE_API_KEY = process.env.XE_API_KEY;
const XE_TARGET_CODES = (process.env.XE_TARGET_CODES || 'EUR,USD,GBP,JPY,CHF,CAD,AUD,CNY,MXN,COP,ARS,BRL,KRW,INR,SEK')
    .split(',')
    .map((c) => c.trim().toUpperCase())
    .filter(Boolean);
const XE_TIMEOUT_MS = Number(process.env.XE_TIMEOUT_MS || 8000);
const ALLOW_SIMULATED_RATES = String(process.env.ALLOW_SIMULATED_RATES || 'false').toLowerCase() === 'true';
const FALLBACK_RATES_URL = process.env.FALLBACK_RATES_URL || 'https://api.exchangerate.host/latest';

let ratesCache = { expiresAt: 0, data: null, base: 'EUR' };

exports.guardar = async (req, res) => {
    try {
        const { id_usuario, cantidad, resultado, origen, destino } = req.body;
        const respuesta = await divisasService.guardarTransaccion(id_usuario, cantidad, resultado, origen, destino);
        res.status(201).json(respuesta);
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

async function fetchXeRates(base, targets) {
    if (!XE_API_ID || !XE_API_KEY) {
        throw new Error('API XE no configurada (falta XE_API_ID o XE_API_KEY).');
    }

    const url = `${XE_API_BASE_URL}/convert_from.json`;
    const params = { from: base, to: targets.join(','), amount: 1 };
    const { data } = await axios.get(url, {
        params,
        auth: { username: XE_API_ID, password: XE_API_KEY },
        timeout: XE_TIMEOUT_MS,
    });

    if (!data || !Array.isArray(data.to)) {
        throw new Error('Respuesta inesperada de la API de XE.');
    }

    const rates = { [base]: 1 };
    for (const item of data.to) {
        const code = (item.quotecurrency || item.currency || item.code || '').toUpperCase();
        const rate = typeof item.mid === 'number'
            ? item.mid
            : (typeof item.rate === 'number' ? item.rate : Number(item.value));
        if (code && !Number.isNaN(rate)) {
            rates[code] = rate;
        }
    }

    const date = data.timestamp
        ? new Date(isNaN(Number(data.timestamp)) ? data.timestamp : Number(data.timestamp) * 1000).toISOString()
        : new Date().toISOString();

    return { rates, date, provider: 'XE' };
}

async function fetchFallbackRates(base, targets) {
    const url = FALLBACK_RATES_URL.includes('{base}')
        ? FALLBACK_RATES_URL.replace('{base}', base)
        : FALLBACK_RATES_URL;

    const params = {};
    if (!FALLBACK_RATES_URL.includes('{base}')) {
        params.base = base;
        params.symbols = targets.join(',');
    }

    const { data } = await axios.get(url, { params, timeout: 8000 });

    let rates;
    let date;

    // exchangerate.host style: { rates: {...}, date: 'YYYY-MM-DD' }
    if (data && data.rates) {
        rates = data.rates;
        date = data.date;
    }
    // open.er-api.com style: { result: 'success', base_code: 'EUR', rates: {...}, time_last_update_utc: '...' }
    if (!rates && data && data.result === 'success' && data.rates) {
        rates = data.rates;
        date = data.time_last_update_utc;
    }

    if (!rates) {
        throw new Error('Respuesta inesperada del fallback de tasas.');
    }

    const normalizedRates = {};
    Object.entries(rates).forEach(([code, value]) => {
        const upper = String(code).toUpperCase();
        const number = typeof value === 'number' ? value : Number(value);
        if (upper && !Number.isNaN(number)) {
            normalizedRates[upper] = number;
        }
    });

    normalizedRates[base] = 1;

    const filteredRates = {};
    [base, ...targets].forEach((code) => {
        if (Object.prototype.hasOwnProperty.call(normalizedRates, code)) {
            filteredRates[code] = normalizedRates[code];
        }
    });

    const finalDate = date ? new Date(date).toISOString() : new Date().toISOString();
    return { rates: filteredRates, date: finalDate, provider: 'fallback' };
}

function isSimulated(rates, base) {
    const values = Object.entries(rates)
        .filter(([code]) => code !== base)
        .map(([, value]) => Number(value))
        .filter((v) => !Number.isNaN(v));
    if (values.length < 2) return false;
    const first = values[0];
    const allSame = values.every((v) => Math.abs(v - first) < 1e-6);
    return allSame;
}

exports.rates = async (req, res) => {
    const base = (req.query.base || 'EUR').toUpperCase();
    const now = Date.now();

    if (ratesCache.data && ratesCache.expiresAt > now && ratesCache.base === base) {
        return res.status(200).json({ success: true, ...ratesCache.data });
    }

    const targets = XE_TARGET_CODES.filter((code) => code && code !== base);
    if (targets.length === 0) {
        return res.status(500).json({ success: false, error: 'No hay divisas configuradas en XE_TARGET_CODES.' });
    }

    let response;
    let simulated = false;

    try {
        response = await fetchXeRates(base, targets);
        simulated = isSimulated(response.rates, base);
        if (simulated && !ALLOW_SIMULATED_RATES) {
            throw new Error('Tasas simuladas detectadas, se intentará fallback.');
        }
    } catch (error) {
        try {
            response = await fetchFallbackRates(base, targets);
            simulated = false;
        } catch (fallbackError) {
            return res.status(502).json({
                success: false,
                error: 'No se pudieron obtener tasas (XE y fallback fallaron).',
                detail: fallbackError.message || fallbackError.toString(),
            });
        }
    }

    const payload = { base, date: response.date, rates: response.rates, provider: response.provider, simulated };
    ratesCache = { expiresAt: now + CACHE_TTL_MS, data: payload, base };
    return res.status(200).json({ success: true, ...payload });
};

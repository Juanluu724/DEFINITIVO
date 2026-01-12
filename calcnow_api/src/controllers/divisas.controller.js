const https = require('https');
const divisasService = require('../services/divisas.service');

const CACHE_TTL_MS = 10 * 60 * 1000;
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

exports.rates = (req, res) => {
    const base = (req.query.base || 'EUR').toUpperCase();
    const now = Date.now();

    if (ratesCache.data && ratesCache.expiresAt > now && ratesCache.base === base) {
        return res.status(200).json({ success: true, ...ratesCache.data });
    }

    const url = `https://api.exchangerate.host/latest?base=${encodeURIComponent(base)}`;
    https.get(url, (resp) => {
        let raw = '';
        resp.on('data', (chunk) => { raw += chunk; });
        resp.on('end', () => {
            try {
                const json = JSON.parse(raw);
                if (!json || !json.rates) {
                    return res.status(502).json({ success: false, error: 'Invalid API response' });
                }

                const data = { base: json.base, date: json.date, rates: json.rates };
                ratesCache = {
                    expiresAt: now + CACHE_TTL_MS,
                    data,
                    base: base,
                };
                return res.status(200).json({ success: true, ...data });
            } catch (e) {
                return res.status(502).json({ success: false, error: 'Failed to parse API response' });
            }
        });
    }).on('error', () => {
        return res.status(502).json({ success: false, error: 'Failed to fetch rates' });
    });
};

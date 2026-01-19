const express = require('express');
const router = express.Router();
const biController = require('../controllers/bi.controller');

const requireBiKey = (req, res, next) => {
    const expected = process.env.BI_ADMIN_KEY;
    const provided = req.header('x-bi-key');
    if (!expected) {
        return res.status(500).json({ success: false, error: 'BI_ADMIN_KEY no configurada' });
    }
    if (!provided || provided !== expected) {
        return res.status(401).json({ success: false, error: 'No autorizado' });
    }
    return next();
};

router.use(requireBiKey);

router.get('/kpis', biController.kpisGlobales);
router.get('/pie', biController.popularidadModulos);
router.get('/geo/hip', biController.hipotecasPorProvincia);
router.get('/geo/nom', biController.nominasPorProvincia);
router.get('/divisas', biController.divisasPorMoneda);
router.get('/top/hip', biController.topHipotecaProvincia);
router.get('/top/divisa', biController.topDivisa);
router.get('/pdf', biController.pdf);

module.exports = router;

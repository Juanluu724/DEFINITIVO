const express = require('express');
const router = express.Router();
const biController = require('../controllers/bi.controller');
const { requireAuth, requireAdmin } = require('../middlewares/auth.middleware');

router.use(requireAuth);
router.use(requireAdmin);

router.get('/kpis', biController.kpisGlobales);
router.get('/pie', biController.popularidadModulos);
router.get('/geo/hip', biController.hipotecasPorProvincia);
router.get('/geo/nom', biController.nominasPorProvincia);
router.get('/divisas', biController.divisasPorMoneda);
router.get('/top/hip', biController.topHipotecaProvincia);
router.get('/top/divisa', biController.topDivisa);
router.get('/all', biController.all);
router.get('/pdf', biController.pdf);

module.exports = router;

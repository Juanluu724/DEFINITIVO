const express = require('express');
const router = express.Router();
const controller = require('../controllers/hipoteca.controller');

// Rutas Públicas (o de cálculo)
router.post('/calcular', controller.calcularHipoteca);

// Rutas Privadas (Persistencia)
router.post('/guardar', controller.guardarHipoteca);
router.get('/historial/:id_usuario', controller.getHistorial);
router.delete('/historial/:id', controller.eliminarHistorial);

module.exports = router;
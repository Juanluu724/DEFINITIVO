const express = require('express');
const router = express.Router();
const controller = require('../controllers/divisas.controller');

// Única ruta: POST http://localhost:3000/api/divisas/guardar
router.post('/guardar', controller.guardar);

module.exports = router;
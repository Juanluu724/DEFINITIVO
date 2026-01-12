const express = require('express');
const router = express.Router();
const controller = require('../controllers/divisas.controller');

// POST http://localhost:3000/api/divisas/guardar
router.post('/guardar', controller.guardar);
// GET http://localhost:3000/api/divisas/rates?base=EUR
router.get('/rates', controller.rates);

module.exports = router;


const express = require('express');
const router = express.Router();

const { login, register } = require('../controllers/auth.controller.js');

// RUTA LOGIN
router.post('/login', login);

// RUTA REGISTER
router.post('/register', register);

module.exports = router;
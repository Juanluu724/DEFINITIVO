const hipotecaService = require('../services/hipoteca.service');

exports.calcularHipoteca = (req, res) => {
    try {
        const { monto, interes, anios } = req.body;
        const resultado = hipotecaService.calcularPrestamo(monto, interes, anios);
        res.status(200).json(resultado);
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

exports.guardarHipoteca = async (req, res) => {
    try {
        // Ajustamos los parámetros según lo que espera tu servicio
        const { id_usuario, monto, interes, anios, resultado } = req.body;
        const respuesta = await hipotecaService.guardarSimulacion(id_usuario, monto, interes, anios, resultado);
        res.status(201).json(respuesta);
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.getHistorial = async (req, res) => {
    try {
        const { id_usuario } = req.params;
        const lista = await hipotecaService.historial(id_usuario);
        res.status(200).json({ success: true, data: lista });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.eliminarHistorial = async (req, res) => {
    try {
        const { id } = req.params;
        const resultado = await hipotecaService.eliminar(id);
        res.status(200).json({ success: true, resultado });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
const divisasService = require('../services/divisas.service');

exports.guardar = async (req, res) => {
    try {
        const { id_usuario, cantidad, resultado, origen, destino } = req.body;
        const respuesta = await divisasService.guardarTransaccion(id_usuario, cantidad, resultado, origen, destino);
        res.status(201).json(respuesta);
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
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

exports.guardarHipoteca = async(req, res) => {
    try {
        const { id_usuario, monto, interes, anios, resultado, coste_aportado, localizacion, estado_inmueble, id_simulacion } = req.body;
        const respuesta = await hipotecaService.guardarSimulacion(
            id_usuario,
            monto,
            interes,
            anios,
            resultado,
            { coste_aportado, localizacion, estado_inmueble, id_simulacion }
        );
        res.status(201).json(respuesta);
    } catch (error) {
        const status = error.message.includes('id_usuario') || error.message.includes('número') ? 400 : 500;
        res.status(status).json({ success: false, error: error.message });
    }
};

exports.getHistorial = async (req, res) => {
    try {
        const { id_usuario } = req.params;
        const lista = await hipotecaService.historial(id_usuario);
        res.status(200).json({ success: true, data: lista });
    } catch (error) {
        const status = error.message.includes('numérico') ? 400 : 500;
        res.status(status).json({ success: false, error: error.message });
    }
};

exports.eliminarHistorial = async (req, res) => {
    try {
        const { id } = req.params;
        const resultado = await hipotecaService.eliminar(id);
        res.status(200).json({ success: true, resultado });
    } catch (error) {
        const status = error.message.includes('numérico') ? 400 : 500;
        res.status(status).json({ success: false, error: error.message });
    }
};

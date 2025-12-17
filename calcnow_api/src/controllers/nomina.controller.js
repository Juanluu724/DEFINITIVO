const nominaService = require('../services/nomina.service');

exports.calcular = async(req, res) => {
    try {
        const resultado = nominaService.ejecutarCalculo(req.body);

        let id = null;
        if (req.body.id_usuario) {
            id = await nominaService.guardarDirecto(req.body, resultado);
        }

        res.status(200).json({
            success: true,
            ...resultado,
            id_nomina: id
        });

    } catch (error) {
        console.error(error);
        res.status(400).json({
            success: false,
            error: error.message
        });
    }
};

exports.historial = async(req, res) => {
    try {
        const { id_usuario } = req.params;
        const datos = await nominaService.historial(id_usuario);
        res.status(200).json({ success: true, data: datos });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.eliminar = async(req, res) => {
    try {
        const { id } = req.params;
        const eliminadas = await nominaService.eliminar(id);
        res.status(200).json({ success: true, eliminadas });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};
const nominaService = require('../services/nomina.service');

exports.calcular = async(req, res) => {
    try {
        const { sueldo_bruto_anual, pagas_anuales } = req.body;

        if (sueldo_bruto_anual === undefined || pagas_anuales === undefined) {
            return res.status(400).json({
                success: false,
                error: 'Faltan datos obligatorios para calcular la nómina'
            });
        }

        const resultado = nominaService.ejecutarCalculo(req.body);

        let id = null;
        const idUsuario = Number(req.body.id_usuario);
        if (Number.isFinite(idUsuario)) {
            id = await nominaService.guardarDirecto({ ...req.body, id_usuario: idUsuario }, resultado);
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
        const idUsuario = Number(req.params.id_usuario);
        if (!Number.isFinite(idUsuario)) {
            return res.status(400).json({ success: false, error: 'El id_usuario debe ser numérico' });
        }
        const datos = await nominaService.historial(idUsuario);
        res.status(200).json({ success: true, data: datos });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.eliminar = async(req, res) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isFinite(id)) {
            return res.status(400).json({ success: false, error: 'El id debe ser numérico' });
        }
        const eliminadas = await nominaService.eliminar(id);
        res.status(200).json({ success: true, eliminadas });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

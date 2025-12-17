const HipotecaModel = require('../models/hipoteca.model');

exports.calcularPrestamo = (monto, interes, anios) => {
    const hipoteca = new HipotecaModel(monto, interes, anios);
    return { success: true, data: hipoteca.calcular() };
};

exports.guardarSimulacion = async (idUsuario, monto, interes, anios, resultado) => {
    const id = await HipotecaModel.create({
        id_usuario: idUsuario,
        monto,
        interes,
        anios,
        cuota: resultado.cuota_mensual,
        total: resultado.total_pagado
    });
    return { success: true, id_hipoteca: id };
};

exports.historial = async (idUsuario) => {
    return await HipotecaModel.findByUserId(idUsuario);
};

exports.eliminar = async (id) => {
    return await HipotecaModel.delete(id);
};
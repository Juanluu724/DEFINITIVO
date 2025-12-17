const HipotecaModel = require('../models/hipoteca.model');
const OperacionModel = require('../models/operacion.model');

const validarDatosHipoteca = (monto, interes, anios) => {
    const montoNum = Number(monto);
    const interesNum = Number(interes);
    const aniosNum = Number(anios);

    if (!Number.isFinite(montoNum) || montoNum <= 0) {
        throw new Error('El monto debe ser un número positivo');
    }

    if (!Number.isFinite(interesNum) || interesNum < 0) {
        throw new Error('El interés debe ser un número no negativo');
    }

    if (!Number.isFinite(aniosNum) || aniosNum <= 0) {
        throw new Error('Los años deben ser un número positivo');
    }

    return { monto: montoNum, interes: interesNum, anios: aniosNum };
};

const calcularCuotas = ({ monto, interes, anios }) => {
    const hipoteca = new HipotecaModel(monto, interes, anios);
    return hipoteca.calcular();
};

exports.calcularPrestamo = (monto, interes, anios) => {
    const datos = validarDatosHipoteca(monto, interes, anios);
    return { success: true, data: calcularCuotas(datos) };
};

exports.guardarSimulacion = async(idUsuario, monto, interes, anios, resultado, extras = {}) => {
    const datos = validarDatosHipoteca(monto, interes, anios);
    const usuarioId = Number(idUsuario);

    if (!Number.isFinite(usuarioId)) {
        throw new Error('El id_usuario es obligatorio y debe ser numérico');
    }

    const calculo = resultado && resultado.cuota_mensual && resultado.total_pagado
        ? resultado
        : calcularCuotas(datos);

    const id = await HipotecaModel.create({
        id_usuario: usuarioId,
        monto: datos.monto,
        interes: datos.interes,
        anios: datos.anios,
        cuota: calculo.cuota_mensual,
        total: calculo.total_pagado,
        ...extras
    });

    await OperacionModel.create('HIPOTECA', usuarioId);

    return { success: true, id_hipoteca: id, data: calculo };
};

exports.historial = async(idUsuario) => {
    const usuarioId = Number(idUsuario);
    if (!Number.isFinite(usuarioId)) {
        throw new Error('El id_usuario debe ser numérico');
    }
    return await HipotecaModel.findByUserId(usuarioId);
};

exports.eliminar = async(id) => {
    const historialId = Number(id);
    if (!Number.isFinite(historialId)) {
        throw new Error('El id debe ser numérico');
    }
    return await HipotecaModel.delete(historialId);
};

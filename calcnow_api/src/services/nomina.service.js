const NominaModel = require('../models/nomina.model');

// Ajustes simplificados por comunidad autonoma para IRPF (no oficiales).
const REGION_IRPF_ADJUST = {
    ANDALUCIA: -0.002,
    ARAGON: 0.001,
    ASTURIAS: 0.001,
    BALEARES: 0.001,
    CANARIAS: -0.002,
    CANTABRIA: 0.0,
    'CASTILLA-LA MANCHA': 0.0,
    'CASTILLA Y LEON': 0.0,
    CATALUNA: 0.002,
    CEUTA: -0.003,
    'COMUNIDAD VALENCIANA': 0.001,
    EXTREMADURA: -0.001,
    GALICIA: 0.0,
    'LA RIOJA': -0.001,
    MADRID: -0.003,
    MURCIA: 0.0,
    NAVARRA: 0.001,
    'PAIS VASCO': -0.002,
    MELILLA: -0.003,
};

const normalizeRegion = (value) => (value || '').toString().trim().toUpperCase();

// -------------------------------
// CÁLCULO DE NÓMINA
// -------------------------------
exports.ejecutarCalculo = (entrada) => {
    const brutoAnual = Number(entrada.sueldo_bruto_anual);
    const pagas = Number(entrada.pagas_anuales);

    if (!brutoAnual || brutoAnual <= 0 || !pagas || pagas <= 0) {
        throw new Error("Datos de salario o pagas inválidos");
    }

    const brutoMensual = brutoAnual / pagas;
    const seguridadSocial = brutoMensual * 0.0635;

    const regionKey = normalizeRegion(entrada.ubicacion_fiscal);
    const baseIrpf = 0.15;
    const ajustado = baseIrpf + (REGION_IRPF_ADJUST[regionKey] || 0);
    const irpfRate = Math.max(0, ajustado);
    const irpf = brutoMensual * irpfRate;
    const netoMensual = brutoMensual - seguridadSocial - irpf;

    return {
        salario_bruto_mensual: Number(brutoMensual.toFixed(2)),
        seguridad_social: Number(seguridadSocial.toFixed(2)),
        irpf: Number(irpf.toFixed(2)),
        salario_neto_mensual: Number(netoMensual.toFixed(2)),
    };
};

// -------------------------------
// GUARDAR NÓMINA (SOLO SI HAY USUARIO)
// -------------------------------
exports.guardarDirecto = async(entrada, resultado) => {
    const datosParaGuardar = {
        sueldo_bruto_anual: entrada.sueldo_bruto_anual,
        pagas_anuales: entrada.pagas_anuales,
        edad: entrada.edad,
        ubicacion_fiscal: entrada.ubicacion_fiscal,
        grupo_profesional: entrada.grupo_profesional,
        grado_discapacidad: entrada.grado_discapacidad ? entrada.grado_discapacidad : 0,
        estado_civil: entrada.estado_civil,
        hijos: entrada.hijos ? 1 : 0,
        dependientes: entrada.dependientes ? 1 : 0,
        traslado_trabajo: entrada.traslado_trabajo ? 1 : 0,
        conyuge_rentas_altas: entrada.conyuge_rentas_altas ? 1 : 0,
        cuota_seguridad_social: resultado.seguridad_social,
        sueldo_neto_mensual: resultado.salario_neto_mensual,
        id_usuario: entrada.id_usuario
    };

    return await NominaModel.create(datosParaGuardar);
};

// -------------------------------
exports.historial = async(idUsuario) => {
    return await NominaModel.findByUserId(idUsuario);
};

exports.eliminar = async(id) => {
    return await NominaModel.delete(id);
};

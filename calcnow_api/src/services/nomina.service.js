const NominaModel = require('../models/nomina.model');
const OperacionModel = require('../models/operacion.model');

const toNumberOrNull = (valor, defaultValue = null) => {
    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : defaultValue;
};

const toBinaryFlag = (valor) => valor ? 1 : 0;

// -------------------------------
// CÁLCULO DE NÓMINA
// -------------------------------
exports.ejecutarCalculo = (entrada) => {
    const brutoAnual = Number(entrada.sueldo_bruto_anual);
    const pagas = Number(entrada.pagas_anuales);

    if (!Number.isFinite(brutoAnual) || brutoAnual <= 0 || !Number.isFinite(pagas) || pagas <= 0) {
        throw new Error("Datos de salario o pagas inválidos");
    }

    const brutoMensual = brutoAnual / pagas;
    const seguridadSocial = brutoMensual * 0.0635;
    const irpf = brutoMensual * 0.15;
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
    try {
        const datosParaGuardar = {
            sueldo_bruto_anual: toNumberOrNull(entrada.sueldo_bruto_anual),
            pagas_anuales: toNumberOrNull(entrada.pagas_anuales),
            edad: toNumberOrNull(entrada.edad),
            ubicacion_fiscal: entrada.ubicacion_fiscal || null,
            grupo_profesional: entrada.grupo_profesional || null,
            grado_discapacidad: toNumberOrNull(entrada.grado_discapacidad, 0),
            estado_civil: entrada.estado_civil || null,
            hijos: toNumberOrNull(entrada.hijos, 0),
            dependientes: toNumberOrNull(entrada.dependientes, 0),
            traslado_trabajo: toBinaryFlag(entrada.traslado_trabajo),
            conyuge_rentas_altas: toBinaryFlag(entrada.conyuge_rentas_altas),
            cuota_seguridad_social: resultado.seguridad_social,
            sueldo_neto_mensual: resultado.salario_neto_mensual,
            id_usuario: toNumberOrNull(entrada.id_usuario)
        };

        const idNomina = await NominaModel.create(datosParaGuardar);
        if (datosParaGuardar.id_usuario) {
            await OperacionModel.create('NOMINA', datosParaGuardar.id_usuario);
        }
        return idNomina;
    } catch (error) {
        throw new Error(`No se pudo guardar la nómina: ${error.message}`);
    }
};

// -------------------------------
exports.historial = async(idUsuario) => {
    try {
        return await NominaModel.findByUserId(idUsuario);
    } catch (error) {
        throw new Error(`No se pudo recuperar el historial: ${error.message}`);
    }
};

exports.eliminar = async(id) => {
    try {
        return await NominaModel.delete(id);
    } catch (error) {
        throw new Error(`No se pudo eliminar la nómina: ${error.message}`);
    }
};

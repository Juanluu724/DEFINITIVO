const DivisasModel = require('../models/divisas.model');

exports.guardarTransaccion = async(idUsuario, cantidad, resultado, origen, destino, tasaCambio) => {
    if (!cantidad || !resultado || !origen || !destino) {
        throw new Error("Faltan datos obligatorios para guardar.");
    }

    const tasa = Number(tasaCambio);
    const valorTasa = Number.isFinite(tasa) ? tasa : (Number(resultado) / Number(cantidad));

    const respuesta = await DivisasModel.guardar({
        id_usuario: idUsuario,
        cantidad,
        resultado,
        origen,
        destino,
        valor_tasa: valorTasa
    });

    return { success: true, ...respuesta, message: "Guardado en Base de Datos" };
};
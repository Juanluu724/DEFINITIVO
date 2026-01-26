const DivisasModel = require('../models/divisas.model');

exports.guardarTransaccion = async (idUsuario, cantidad, resultado, origen, destino) => {
    // Solo validamos que lleguen datos basicos
    if (!cantidad || !origen || !destino) {
        throw new Error("Faltan datos obligatorios para guardar.");
    }

    // Llamamos al modelo para que gestione la BD
    const id = await DivisasModel.guardar({
        cantidad,
        resultado,
        origen,
        destino
    });

    return { success: true, id_operacion: id, message: "Guardado en Base de Datos" };
};

const BiModel = require('../models/bi.model');

exports.kpisGlobales = async() => {
    return BiModel.kpisGlobales();
};

exports.popularidadModulos = async() => {
    return BiModel.popularidadModulos();
};

exports.hipotecasPorProvincia = async() => {
    return BiModel.hipotecasPorProvincia();
};

exports.nominasPorProvincia = async() => {
    return BiModel.nominasPorProvincia();
};

exports.divisasPorMoneda = async() => {
    return BiModel.divisasPorMoneda();
};

exports.topHipotecaProvincia = async() => {
    return BiModel.topHipotecaProvincia();
};

exports.topDivisa = async() => {
    return BiModel.topDivisa();
};

exports.getAll = async() => {
    const [
        kpis,
        popularidad,
        hipotecas,
        nominas,
        divisas,
        topHipoteca,
        topDivisa
    ] = await Promise.all([
        BiModel.kpisGlobales(),
        BiModel.popularidadModulos(),
        BiModel.hipotecasPorProvincia(),
        BiModel.nominasPorProvincia(),
        BiModel.divisasPorMoneda(),
        BiModel.topHipotecaProvincia(),
        BiModel.topDivisa()
    ]);

    return {
        kpis,
        popularidad,
        hipotecas,
        nominas,
        divisas,
        topHipoteca,
        topDivisa
    };
};

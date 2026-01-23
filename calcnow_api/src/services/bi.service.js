const BiModel = require('../models/bi.model');

exports.kpisGlobales = async(filters) => {
    return BiModel.kpisGlobales(filters);
};

exports.popularidadModulos = async(filters) => {
    return BiModel.popularidadModulos(filters);
};

exports.hipotecasPorProvincia = async(filters) => {
    return BiModel.hipotecasPorProvincia(filters);
};

exports.nominasPorProvincia = async(filters) => {
    return BiModel.nominasPorProvincia(filters);
};

exports.divisasPorMoneda = async(filters) => {
    return BiModel.divisasPorMoneda(filters);
};

exports.topHipotecaProvincia = async(filters) => {
    return BiModel.topHipotecaProvincia(filters);
};

exports.topDivisa = async(filters) => {
    return BiModel.topDivisa(filters);
};

exports.getAll = async(filters) => {
    const [
        kpis,
        popularidad,
        hipotecas,
        nominas,
        divisas,
        topHipoteca,
        topDivisa
    ] = await Promise.all([
        BiModel.kpisGlobales(filters),
        BiModel.popularidadModulos(filters),
        BiModel.hipotecasPorProvincia(filters),
        BiModel.nominasPorProvincia(filters),
        BiModel.divisasPorMoneda(filters),
        BiModel.topHipotecaProvincia(filters),
        BiModel.topDivisa(filters)
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

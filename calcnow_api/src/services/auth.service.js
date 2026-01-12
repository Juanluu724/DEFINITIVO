const AuthModel = require('../models/auth.model');

exports.login = async(email, password) => {
    try {
        const user = await AuthModel.findByCredentials(email, password);
        if (user) {
            await AuthModel.updateLastAccess(user.id_usuario);
            return { success: true, user, message: "Login correcto" };
        }
        return { success: false, message: "Credenciales incorrectas" };
    } catch (error) {
        throw error;
    }
};

exports.register = async({ email, password, nombre_usuario }) => {
    try {
        const existingUser = await AuthModel.findByEmail(email);
        if (existingUser) return { success: false, message: "El usuario ya existe" };

        const newUser = new AuthModel(email, password);
        if (!newUser.isValid()) return { success: false, message: "Datos invalidos" };

        await AuthModel.create({ nombre_usuario, email, password });
        return { success: true, message: "Usuario creado exitosamente" };
    } catch (error) {
        throw error;
    }
};

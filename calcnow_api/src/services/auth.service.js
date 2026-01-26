const jwt = require('jsonwebtoken');
const AuthModel = require('../models/auth.model');

exports.login = async(email, password) => {
    try {
        const user = await AuthModel.findByCredentials(email, password);
        if (user) {
            const { contrasena, ...safeUser } = user;
            const payload = {
                id: user.id_usuario,
                email: user.correo_electronico,
                role: user.es_admin ? 'admin' : 'user'
            };
            const token = jwt.sign(payload, process.env.JWT_SECRET || 'calcnow_dev_secret', { expiresIn: '12h' });

            return {
                success: true,
                user: { ...safeUser, es_admin: !!user.es_admin },
                token,
                message: "Login correcto"
            };
        }
        return { success: false, message: "Credenciales incorrectas" };
    } catch (error) {
        throw error;
    }
};

exports.register = async(email, password) => {
    try {
        const existingUser = await AuthModel.findByEmail(email);
        if (existingUser) return { success: false, message: "El usuario ya existe" };

        const newUser = new AuthModel(email, password);
        if (!newUser.isValid()) return { success: false, message: "Datos invalidos" };

        await AuthModel.create(email, password);
        return { success: true, message: "Usuario creado exitosamente" };
    } catch (error) {
        throw error;
    }
};

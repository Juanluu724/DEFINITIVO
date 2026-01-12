const authService = require('../services/auth.service');

exports.login = async(req, res) => {
    const { email, password } = req.body;

    try {
        const result = await authService.login(email, password);

        if (result.success) {
            return res.json(result);
        } else {
            return res.status(401).json(result);
        }
    } catch (error) {
        console.error(" Error Login:", error);
        return res.status(500).json({ success: false, message: "Error interno" });
    }
};

exports.register = async(req, res) => {
    const { email, password, nombre_usuario } = req.body;

    try {
        const result = await authService.register({ email, password, nombre_usuario });

        if (result.success) {
            return res.json(result);
        } else {
            return res.status(400).json(result);
        }
    } catch (error) {
        console.error(" Error Register:", error);
        return res.status(500).json({ success: false, message: "Error interno" });
    }
};
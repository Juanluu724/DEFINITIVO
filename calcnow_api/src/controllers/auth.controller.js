const authService = require('../services/auth.service');

exports.login = async(req, res) => {
    console.log(" Login Request:", req.body);
    const { email, password } = req.body;

    try {
        // Llamamos al nuevo servicio
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
    console.log(" Register Request:", req.body);
    const { email, password } = req.body;

    try {
        // Llamamos al nuevo servicio
        const result = await authService.register(email, password);

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
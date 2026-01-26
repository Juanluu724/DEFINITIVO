const jwt = require('jsonwebtoken');

const getTokenFromHeader = (req) => {
    const authHeader = req.header('Authorization') || '';
    if (!authHeader.toLowerCase().startsWith('bearer ')) return null;
    return authHeader.slice(7).trim();
};

const requireAuth = (req, res, next) => {
    const token = getTokenFromHeader(req);
    if (!token) {
        return res.status(401).json({ success: false, message: 'Token no proporcionado' });
    }

    try {
        const payload = jwt.verify(token, process.env.JWT_SECRET || 'calcnow_dev_secret');
        req.user = payload;
        return next();
    } catch (err) {
        return res.status(401).json({ success: false, message: 'Token inválido' });
    }
};

const requireAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({ success: false, message: 'No autenticado' });
    }
    if (req.user.role !== 'admin') {
        return res.status(403).json({ success: false, message: 'Solo administradores' });
    }
    return next();
};

module.exports = { requireAuth, requireAdmin };

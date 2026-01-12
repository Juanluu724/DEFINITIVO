const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// RUTAS
app.use('/api/nomina', require('./routes/nomina.routes'));
app.use('/api/divisas', require('./routes/divisas.routes'));
app.use('/api/hipoteca', require('./routes/hipoteca.routes'));
app.use('/api/auth', require('./routes/auth.routes'));

// SERVIDOR
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`API CalcNow corriendo en http://localhost:${PORT}`);
});

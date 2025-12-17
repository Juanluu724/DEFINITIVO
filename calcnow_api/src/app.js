const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// RUTAS
app.use('/api/nomina', require('./routes/nomina.routes'));

// SERVIDOR
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`API CalcNow corriendo en http://localhost:${PORT}`);
});
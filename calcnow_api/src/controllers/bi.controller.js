const biService = require('../services/bi.service');
const PDFDocument = require('pdfkit');

exports.kpisGlobales = async(req, res) => {
    try {
        const data = await biService.kpisGlobales();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.popularidadModulos = async(req, res) => {
    try {
        const data = await biService.popularidadModulos();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.hipotecasPorProvincia = async(req, res) => {
    try {
        const data = await biService.hipotecasPorProvincia();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.nominasPorProvincia = async(req, res) => {
    try {
        const data = await biService.nominasPorProvincia();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.divisasPorMoneda = async(req, res) => {
    try {
        const data = await biService.divisasPorMoneda();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.topHipotecaProvincia = async(req, res) => {
    try {
        const data = await biService.topHipotecaProvincia();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.topDivisa = async(req, res) => {
    try {
        const data = await biService.topDivisa();
        res.status(200).json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

exports.pdf = async(req, res) => {
    try {
        const data = await biService.getAll();
        const doc = new PDFDocument({ margin: 40, size: 'A4' });

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'attachment; filename=calcnow_bi.pdf');
        doc.pipe(res);

        const colors = ['#0B4F6C', '#01BAEF', '#F18F01', '#6B7FD7', '#2E294E', '#7CB518'];
        const margin = 40;
        const contentWidth = doc.page.width - margin * 2;
        let y = margin;

        const safeNumber = (value) => {
            const n = Number(value);
            return Number.isFinite(n) ? n : 0;
        };

        const pickLabelValue = (row) => {
            if (!row || typeof row !== 'object') {
                return { label: 'N/A', value: 0 };
            }
            const entries = Object.entries(row);
            const label = entries[0] ? String(entries[0][1]) : 'N/A';
            const value = entries[1] ? safeNumber(entries[1][1]) : 0;
            return { label, value };
        };

        const ensureSpace = (height) => {
            if (y + height > doc.page.height - margin) {
                doc.addPage();
                y = margin;
            }
        };

        const drawBand = () => {
            ensureSpace(20);
            doc.strokeColor('#E2E8F0').lineWidth(1).moveTo(margin, y + 10).lineTo(margin + contentWidth, y + 10).stroke();
            y += 18;
        };

        const drawSectionTitle = (text) => {
            ensureSpace(26);
            doc.fillColor('#0B4F6C').fontSize(16).text(text, margin, y);
            y += 22;
        };

        const drawCard = (title, height, drawBody) => {
            ensureSpace(height + 14);
            doc.fillColor('#FFFFFF').roundedRect(margin, y, contentWidth, height, 8).fill();
            doc.strokeColor('#E2E8F0').lineWidth(1).roundedRect(margin, y, contentWidth, height, 8).stroke();
            doc.fillColor('#111827').fontSize(11).text(title, margin + 12, y + 10);
            drawBody(margin + 12, y + 28, contentWidth - 24, height - 34);
            y += height + 12;
        };

        const drawKpiRow = (labelLeft, valueLeft, labelRight, valueRight) => {
            const cardHeight = 70;
            ensureSpace(cardHeight + 12);
            const gap = 12;
            const cardWidth = (contentWidth - gap) / 2;
            const baseY = y;

            doc.fillColor('#FFFFFF').roundedRect(margin, baseY, cardWidth, cardHeight, 8).fill();
            doc.strokeColor('#E2E8F0').lineWidth(1).roundedRect(margin, baseY, cardWidth, cardHeight, 8).stroke();
            doc.fillColor('#6B7280').fontSize(9).text(labelLeft, margin + 12, baseY + 10);
            doc.fillColor('#0B4F6C').fontSize(20).text(String(valueLeft), margin + 12, baseY + 28);

            const rightX = margin + cardWidth + gap;
            doc.fillColor('#FFFFFF').roundedRect(rightX, baseY, cardWidth, cardHeight, 8).fill();
            doc.strokeColor('#E2E8F0').lineWidth(1).roundedRect(rightX, baseY, cardWidth, cardHeight, 8).stroke();
            doc.fillColor('#6B7280').fontSize(9).text(labelRight, rightX + 12, baseY + 10);
            doc.fillColor('#0B4F6C').fontSize(20).text(String(valueRight), rightX + 12, baseY + 28);

            y += cardHeight + 12;
        };

        const drawPie = (items, x, yTop, width, height) => {
            const total = items.reduce((acc, item) => acc + item.value, 0);
            if (items.length === 0 || total === 0) {
                doc.fillColor('#9CA3AF').fontSize(10).text('Sin datos', x, yTop + 12);
                return;
            }

            const centerX = x + 70;
            const centerY = yTop + height / 2;
            const radius = Math.min(50, height / 2 - 6);
            let angle = -Math.PI / 2;

            items.forEach((item, index) => {
                const ratio = total > 0 ? item.value / total : 0;
                const slice = ratio * Math.PI * 2;
                const endAngle = angle + slice;

                doc
                    .save()
                    .moveTo(centerX, centerY)
                    .lineTo(
                        centerX + radius * Math.cos(angle),
                        centerY + radius * Math.sin(angle)
                    )
                    .arc(centerX, centerY, radius, angle * 180 / Math.PI, endAngle * 180 / Math.PI)
                    .lineTo(centerX, centerY)
                    .fill(colors[index % colors.length]);

                angle = endAngle;
            });

            const legendX = x + 150;
            let legendY = yTop + 10;
            items.forEach((item, index) => {
                const ratio = total > 0 ? (item.value / total) * 100 : 0;
                doc.fillColor(colors[index % colors.length]).rect(legendX, legendY + 3, 10, 10).fill();
                doc.fillColor('#111827').fontSize(9).text(
                    `${item.label} (${ratio.toFixed(1)}%)`,
                    legendX + 16,
                    legendY
                );
                legendY += 14;
            });
        };

        const drawBars = (items, x, yTop, width, height) => {
            if (items.length === 0) {
                doc.fillColor('#9CA3AF').fontSize(10).text('Sin datos', x, yTop + 12);
                return;
            }

            const total = items.reduce((acc, item) => acc + item.value, 0);
            const barAreaWidth = width - 160;
            let rowY = yTop + 6;

            items.forEach((item, index) => {
                const ratio = total > 0 ? item.value / total : 0;
                const barWidth = Math.max(6, barAreaWidth * ratio);
                doc.fillColor('#111827').fontSize(9).text(item.label, x, rowY + 2);
                doc.fillColor(colors[index % colors.length]).rect(x + 110, rowY + 6, barWidth, 8).fill();
                doc.fillColor('#111827').text(`${(ratio * 100).toFixed(1)}%`, x + 120 + barAreaWidth, rowY + 2);
                rowY += 14;
            });
        };

        const drawHeader = () => {
            doc.fillColor('#0B4F6C').rect(margin, y, contentWidth, 48).fill();
            doc.fillColor('#FFFFFF').fontSize(18).text('CalcNow BI Report', margin + 14, y + 14);
            doc.fillColor('#E2E8F0').fontSize(9).text(
                `Generated: ${new Date().toLocaleString()}`,
                margin + 14,
                y + 32
            );
            y += 60;
        };

        drawHeader();
        drawBand();
        drawBand();
        drawSectionTitle('Global');

        const kpis = data.kpis && data.kpis[0] ? data.kpis[0] : {};
        const usuariosRegistrados = safeNumber(kpis.usuarios_registrados);
        const usuariosActivos = safeNumber(kpis.usuarios_activos);

        drawBand();
        drawKpiRow('Usuarios registrados', usuariosRegistrados, 'Usuarios activos', usuariosActivos);

        drawCard('Uso total de la App (%)', 150, (x, yTop, width, height) => {
            drawPie(data.popularidad.map(pickLabelValue), x, yTop, width, height);
        });

        drawCard('Usuarios registrados vs usuarios reales', 110, (x, yTop, width, height) => {
            drawBars(
                [
                    { label: 'Registrados', value: usuariosRegistrados },
                    { label: 'Activos', value: usuariosActivos }
                ],
                x,
                yTop,
                width,
                height
            );
        });

        drawBand();

        drawBand();
        drawSectionTitle('Segmentacion');

        drawBand();
        const hipotecasItems = data.hipotecas.map(pickLabelValue);
        const hipotecasHeight = Math.min(200, Math.max(90, 40 + hipotecasItems.length * 14));
        drawCard('Hipotecas por provincia (%)', hipotecasHeight, (x, yTop, width, height) => {
            drawBars(hipotecasItems, x, yTop, width, height);
        });

        const nominasItems = data.nominas.map(pickLabelValue);
        const nominasHeight = Math.min(200, Math.max(90, 40 + nominasItems.length * 14));
        drawCard('Nominas por provincia (%)', nominasHeight, (x, yTop, width, height) => {
            drawBars(nominasItems, x, yTop, width, height);
        });

        const divisasItems = data.divisas.map(pickLabelValue);
        const divisasHeight = Math.min(200, Math.max(90, 40 + divisasItems.length * 14));
        drawCard('Divisas por moneda (%)', divisasHeight, (x, yTop, width, height) => {
            drawBars(divisasItems, x, yTop, width, height);
        });

        drawBand();

        drawBand();
        drawSectionTitle('Resumen');

        const topHipoteca = data.topHipoteca && data.topHipoteca[0] ? data.topHipoteca[0] : {};
        const topDivisa = data.topDivisa && data.topDivisa[0] ? data.topDivisa[0] : {};
        drawCard('Resumen ejecutivo', 110, (x, yTop) => {
            doc.fillColor('#111827').fontSize(11).text(
                `Lugar hipotecas mas buscado: ${pickLabelValue(topHipoteca).label}`,
                x,
                yTop
            );
            doc.fillColor('#111827').fontSize(11).text(
                `Divisa lider: ${pickLabelValue(topDivisa).label}`,
                x,
                yTop + 18
            );
            doc.fillColor('#111827').fontSize(11).text(
                `Usuarios registrados: ${usuariosRegistrados}`,
                x,
                yTop + 36
            );
            doc.fillColor('#111827').fontSize(11).text(
                `Usuarios que lo han usado: ${usuariosActivos}`,
                x,
                yTop + 54
            );
        });

        doc.end();
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};

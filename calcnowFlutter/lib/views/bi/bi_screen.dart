import 'package:flutter/material.dart';
import '../../services/bi_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/pdf_download.dart'
    if (dart.library.html) '../../utils/pdf_download_web.dart';

class BiScreen extends StatefulWidget {
  const BiScreen({super.key});

  @override
  State<BiScreen> createState() => _BiScreenState();
}

class _BiScreenState extends State<BiScreen> {
  final BiService _service = BiService();

  bool _loading = true;
  String? _error;
  bool _exporting = false;
  bool _isAdmin = false;
  bool _sessionChecked = false;

  Map<String, dynamic> _kpis = {};
  List<Map<String, dynamic>> _popularidad = [];
  List<Map<String, dynamic>> _hipotecas = [];
  List<Map<String, dynamic>> _nominas = [];
  List<Map<String, dynamic>> _divisas = [];
  Map<String, dynamic> _topHipoteca = {};
  Map<String, dynamic> _topDivisa = {};
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _initAccess();
  }

  Future<void> _initAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final isAdmin = prefs.getBool('is_admin') ?? false;
    if (!mounted) return;

    if (!isAdmin) {
      setState(() {
        _isAdmin = false;
        _sessionChecked = true;
        _loading = false;
        _error = 'Acceso solo para administradores';
      });
      return;
    }

    if (token == null || token.isEmpty) {
      setState(() {
        _isAdmin = true;
        _sessionChecked = true;
        _loading = false;
        _error = 'Inicia sesion nuevamente para acceder al BI';
      });
      return;
    }

    setState(() {
      _isAdmin = true;
      _sessionChecked = true;
    });
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!_isAdmin) {
      setState(() {
        _error = 'Acceso solo para administradores';
        _loading = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getAll(from: _fromDate, to: _toDate);
      final kpis = _toMaps(data['kpis'] ?? []);
      final popularidad = _toMaps(data['popularidad'] ?? []);
      final hipotecas = _toMaps(data['hipotecas'] ?? []);
      final nominas = _toMaps(data['nominas'] ?? []);
      final divisas = _toMaps(data['divisas'] ?? []);
      final topHipoteca = _toMaps(data['topHipoteca'] ?? []);
      final topDivisa = _toMaps(data['topDivisa'] ?? []);

      setState(() {
        _kpis = kpis.isNotEmpty ? kpis.first : {};
        _popularidad = popularidad;
        _hipotecas = _filterWithProvincia(hipotecas);
        _nominas = nominas;
        _divisas = divisas;
        _topHipoteca = topHipoteca.isNotEmpty ? topHipoteca.first : {};
        _topDivisa = topDivisa.isNotEmpty ? topDivisa.first : {};
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudo cargar el BI';
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _toMaps(List<dynamic> data) {
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      if (kIsWeb) {
        final bytes = await _service.getPdf(from: _fromDate, to: _toDate);
        await downloadPdfBytes(bytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descarga iniciada en el navegador')),
        );
      } else {
        final bytes = await _service.getPdf(from: _fromDate, to: _toDate);
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/calcnow_bi.pdf');
        await file.writeAsBytes(bytes, flush: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado en ${file.path}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_sessionChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFFEFF3F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF3F8),
        appBar: AppBar(
          title: const Text('Inteligencia de mercado'),
        ),
        body: const Center(
          child: Text('Acceso restringido a administradores'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      appBar: AppBar(
        title: const Text('Inteligencia de mercado'),
        actions: [
          IconButton(
            onPressed: _exporting ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generar PDF',
          ),
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _filterRow(),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _exporting ? null : _exportPdf,
                          icon: _exporting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(
                            _exporting ? 'Generando...' : 'Generar PDF',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B4F6C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _sectionTitle('KPIs'),
                        _kpiGrid(_kpis),
                        const SizedBox(height: 24),
                        _sectionTitle('Hipotecas por provincia'),
                        _listSection(_hipotecas,
                            emptyMessage:
                                'Aun no hay informacion suficiente para generar estadisticas.'),
                        const SizedBox(height: 24),
                        _sectionTitle('Nominas por provincia'),
                        _listSection(_nominas,
                            emptyMessage:
                                'Aun no hay informacion suficiente para generar estadisticas.'),
                        const SizedBox(height: 24),
                        _sectionTitle('Divisas por moneda'),
                        _listSection(_divisas,
                            emptyMessage:
                                'Aun no hay informacion suficiente para generar estadisticas.'),
                        const SizedBox(height: 24),
                        _sectionTitle('Top hipoteca'),
                        _keyValueCard(_topHipoteca,
                            emptyMessage:
                                'Aun no hay informacion suficiente para generar estadisticas.'),
                        const SizedBox(height: 24),
                        _sectionTitle('Top divisa'),
                        _keyValueCard(_topDivisa,
                            emptyMessage:
                                'Aun no hay informacion suficiente para generar estadisticas.'),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
    );
  }

  Widget _kpiGrid(Map<String, dynamic> data) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Aun no hay informacion suficiente para generar estadisticas.'),
      );
    }

    final entries = data.entries
        .where((e) => !_isEmptyKpiValue(e.value))
        .toList();
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Aun no hay informacion suficiente para generar estadisticas.'),
      );
    }
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: entries.map((e) => _kpiCard(e.key, e.value)).toList(),
    );
  }

  Widget _kpiCard(String label, dynamic value) {
    final displayLabel = _kpiLabel(label);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _listSection(List<Map<String, dynamic>> data,
      {String emptyMessage = 'Aun no hay informacion suficiente.'}) {
    if (data.isEmpty || !_hasMeaningfulData(data)) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(emptyMessage),
      );
    }

    return Column(
      children: data.map((row) => _listRowCard(row)).toList(),
    );
  }

  Widget _listRowCard(Map<String, dynamic> row) {
    final entries = row.entries.toList();
    final first = entries.isNotEmpty ? entries[0] : null;
    final second = entries.length > 1 ? entries[1] : null;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              first == null
                  ? '-'
                  : '${first.key}: ${_formatValue(first.key, first.value)}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              second == null
                  ? ''
                  : '${second.key}: ${_formatValue(second.key, second.value)}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _kpiLabel(String key) {
    switch (key.toLowerCase()) {
      case 'usuarios_registrados':
        return 'Usuarios registrados';
      case 'usuarios_activos':
        return 'Usuarios activos';
      case 'total_hipotecas':
        return 'Total hipotecas';
      case 'region_mas_hipotecas':
        return 'Region con mas hipotecas';
      default:
        return key;
    }
  }

  bool _isEmptyKpiValue(dynamic value) {
    if (value == null) return true;
    final text = value.toString().trim();
    if (text.isEmpty) return true;
    if (text.toLowerCase() == 'no especificado') return true;
    return false;
  }

  Widget _keyValueCard(Map<String, dynamic> row,
      {String emptyMessage = 'Aun no hay informacion suficiente.'}) {
    if (row.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(emptyMessage),
      );
    }

    final entries = row.entries.toList();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${e.key}: ${_formatValue(e.key, e.value)}'),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _filterRow() {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _dateButton('Desde', _fromDate, (picked) {
          setState(() => _fromDate = picked);
          _loadData();
        }),
        _dateButton('Hasta', _toDate, (picked) {
          setState(() => _toDate = picked);
          _loadData();
        }),
        OutlinedButton(
          onPressed: (_fromDate == null && _toDate == null)
              ? null
              : () {
                  setState(() {
                    _fromDate = null;
                    _toDate = null;
                  });
                  _loadData();
                },
          child: const Text('Limpiar'),
        ),
      ],
    );
  }

  Widget _dateButton(
      String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    final text = value == null ? label : '${label}: ${_formatDate(value)}';
    return OutlinedButton(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onPicked(picked);
        }
      },
      child: Text(text),
    );
  }

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  bool _hasMeaningfulData(List<Map<String, dynamic>> data) {
    for (final row in data) {
      for (final value in row.values) {
        final n = num.tryParse(value.toString());
        if (n != null && n > 0) {
          return true;
        }
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _filterWithProvincia(List<Map<String, dynamic>> data) {
    return data.where((row) {
      for (final entry in row.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key.contains('provincia')) {
          final value = entry.value;
          if (value == null) return false;
          final text = value.toString().trim();
          if (text.isEmpty || text.toLowerCase() == 'null') return false;
          return true;
        }
      }
      return false;
    }).toList();
  }

  String _formatValue(String key, dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') {
      if (key.toLowerCase().contains('provincia')) {
        return 'Provincia no especificada';
      }
      return 'No especificado';
    }
    return value.toString();
  }
}

import 'package:flutter/material.dart';
import '../../services/bi_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
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

  Map<String, dynamic> _kpis = {};
  List<Map<String, dynamic>> _popularidad = [];
  List<Map<String, dynamic>> _hipotecas = [];
  List<Map<String, dynamic>> _nominas = [];
  List<Map<String, dynamic>> _divisas = [];
  Map<String, dynamic> _topHipoteca = {};
  Map<String, dynamic> _topDivisa = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getKpis(),
        _service.getPopularidad(),
        _service.getHipotecasPorProvincia(),
        _service.getNominasPorProvincia(),
        _service.getDivisasPorMoneda(),
        _service.getTopHipoteca(),
        _service.getTopDivisa(),
      ]);

      final kpis = _toMaps(results[0]);
      final popularidad = _toMaps(results[1]);
      final hipotecas = _toMaps(results[2]);
      final nominas = _toMaps(results[3]);
      final divisas = _toMaps(results[4]);
      final topHipoteca = _toMaps(results[5]);
      final topDivisa = _toMaps(results[6]);

      setState(() {
        _kpis = kpis.isNotEmpty ? kpis.first : {};
        _popularidad = popularidad;
        _hipotecas = hipotecas;
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
        final bytes = await _service.getPdf();
        await downloadPdfBytes(bytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descarga iniciada en el navegador')),
        );
      } else {
        final bytes = await _service.getPdf();
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
    if (BiService.biKey.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFEFF3F8),
        appBar: AppBar(
          title: const Text('Inteligencia de mercado'),
        ),
        body: const Center(
          child: Text('Acceso restringido'),
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
                        _sectionTitle('Popularidad de modulos'),
                        _listSection(_popularidad),
                        const SizedBox(height: 24),
                        _sectionTitle('Hipotecas por provincia'),
                        _listSection(_hipotecas),
                        const SizedBox(height: 24),
                        _sectionTitle('Nominas por provincia'),
                        _listSection(_nominas),
                        const SizedBox(height: 24),
                        _sectionTitle('Divisas por moneda'),
                        _listSection(_divisas),
                        const SizedBox(height: 24),
                        _sectionTitle('Top hipoteca'),
                        _keyValueCard(_topHipoteca),
                        const SizedBox(height: 24),
                        _sectionTitle('Top divisa'),
                        _keyValueCard(_topDivisa),
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
        child: Text('Sin datos'),
      );
    }

    final entries = data.entries.toList();
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: entries.map((e) => _kpiCard(e.key, e.value)).toList(),
    );
  }

  Widget _kpiCard(String label, dynamic value) {
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
            label,
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

  Widget _listSection(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Sin datos'),
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
              first == null ? '-' : '${first.key}: ${first.value}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              second == null ? '' : '${second.key}: ${second.value}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _keyValueCard(Map<String, dynamic> row) {
    if (row.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text('Sin datos'),
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
                child: Text('${e.key}: ${e.value}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/divisas_service.dart';

class Currency {
  final String code;
  final String name;
  final double rate;

  Currency({required this.code, required this.name, required this.rate});
}

class DivisasScreen extends StatefulWidget {
  const DivisasScreen({super.key});

  @override
  _DivisasScreenState createState() => _DivisasScreenState();
}

class _DivisasScreenState extends State<DivisasScreen> {
  final DivisasService _service = DivisasService();
  final Map<String, String> _currencyNames = {
    'EUR': 'Euro',
    'USD': 'Dolar estadounidense',
    'GBP': 'Libra esterlina',
    'JPY': 'Yen japones',
    'CHF': 'Franco suizo',
    'CAD': 'Dolar canadiense',
    'AUD': 'Dolar australiano',
    'CNY': 'Yuan chino',
    'MXN': 'Peso mexicano',
    'COP': 'Peso colombiano',
    'ARS': 'Peso argentino',
    'BRL': 'Real brasileno',
    'KRW': 'Won surcoreano',
    'INR': 'Rupia india',
    'SEK': 'Corona sueca',
  };
  final String _baseCurrency = 'EUR';
  List<Currency> _currencies = [];
  bool _loadingRates = false;
  String _ratesError = '';

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  late Currency _fromCurrency;
  late Currency _toCurrency;
  int? _userId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _currencies = _fallbackCurrencies();
    _fromCurrency = _currencies.firstWhere((c) => c.code == 'USD',
        orElse: () => _currencies.first);
    _toCurrency = _currencies.firstWhere((c) => c.code == 'EUR',
        orElse: () => _currencies.first);
    _loadUserId();
    _loadRates();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _userId = prefs.getInt('user_id'));
  }

  List<Currency> _fallbackCurrencies() {
    return _currencyNames.entries.map((e) {
      final rate = e.key == _baseCurrency ? 1.0 : 1.0;
      return Currency(code: e.key, name: e.value, rate: rate);
    }).toList();
  }

  Future<void> _loadRates() async {
    setState(() {
      _loadingRates = true;
      _ratesError = '';
    });
    try {
      final response = await _service.fetchRates(base: _baseCurrency);
      final rates = response['rates'] as Map<String, dynamic>;
      final updated = <Currency>[];
      _currencyNames.forEach((code, name) {
        final raw = rates[code];
        final rate =
            raw is num ? raw.toDouble() : (code == _baseCurrency ? 1.0 : null);
        if (rate != null) {
          updated.add(Currency(code: code, name: name, rate: rate));
        }
      });
      if (updated.isNotEmpty) {
        setState(() {
          _currencies = updated;
          _fromCurrency = _currencies.firstWhere((c) => c.code == 'USD',
              orElse: () => _currencies.first);
          _toCurrency = _currencies.firstWhere((c) => c.code == 'EUR',
              orElse: () => _currencies.first);
        });
      }
    } catch (e) {
      setState(() => _ratesError = 'No se pudo actualizar');
    } finally {
      if (mounted) {
        setState(() => _loadingRates = false);
      }
    }
  }

  void _calculate() {
    if (_amountController.text.isEmpty) {
      _resultController.text = "";
      return;
    }

    final double amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final double result = (amount / _fromCurrency.rate) * _toCurrency.rate;

    setState(() {
      _resultController.text = result.toStringAsFixed(2);
    });
  }

  Future<void> _guardar() async {
    if (_userId == null) {
      _show("Inicia sesion para guardar la operacion");
      return;
    }

    final amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;
    final result =
        double.tryParse(_resultController.text.replaceAll(',', '.')) ?? 0.0;

    if (amount <= 0 || result <= 0) {
      _show("Calcula una conversion valida antes de guardar");
      return;
    }

    setState(() => _saving = true);
    try {
      final response = await _service.guardarTransaccion(
        idUsuario: _userId!,
        cantidad: amount,
        resultado: result,
        origen: _fromCurrency.code,
        destino: _toCurrency.code,
      );
      final id = response["id_operacion"];
      _show("Guardado. Ref: $id");
    } catch (e) {
      _show("No se pudo guardar: $e");
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _pillTextField({
    required TextEditingController controller,
    bool readOnly = false,
    String? hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.black, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF0077CC), width: 2),
        ),
      ),
    );
  }

  Widget _currencyCard({
    required String title,
    required Currency selected,
    required void Function(Currency?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 6),
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: selected,
              isExpanded: true,
              items: _currencies.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(c.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      ),
                      const SizedBox(width: 8),
                      Text(c.code,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cambio divisas',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Convierte al instante con el mismo esquema visual',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.home_outlined),
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.black, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tasas en tiempo real",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        if (_loadingRates)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    if (_ratesError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _ratesError,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Importe',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 8),
                    _pillTextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      hint: '0.00',
                      onChanged: (_) => _calculate(),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _currencyCard(
                            title: 'Desde',
                            selected: _fromCurrency,
                            onChanged: (v) {
                              setState(() => _fromCurrency = v!);
                              _calculate();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 32),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: const Icon(Icons.swap_horiz),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _currencyCard(
                            title: 'A',
                            selected: _toCurrency,
                            onChanged: (v) {
                              setState(() => _toCurrency = v!);
                              _calculate();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text('Conversion',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _pillTextField(
                      controller: _resultController,
                      readOnly: true,
                      hint: '0.00',
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077CC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Guardar",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "CALC",
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "NOW",
                    style: TextStyle(
                      fontSize: 58,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF46899F),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Image.asset(
                    'assets/logo_transparente.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

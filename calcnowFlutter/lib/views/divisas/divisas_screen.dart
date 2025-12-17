import 'package:flutter/material.dart';

// --- CLASE MODELO (Datos de la moneda) ---
class Currency {
  final String code;
  final String name;
  final double rate;

  Currency({required this.code, required this.name, required this.rate});
}

// --- PANTALLA PRINCIPAL ---
class DivisasScreen extends StatefulWidget {
  const DivisasScreen({super.key});

  @override
  _DivisasScreenState createState() => _DivisasScreenState();
}

class _DivisasScreenState extends State<DivisasScreen> {
  final List<Currency> _staticCurrencies = [
    Currency(code: 'EUR', name: 'Euro', rate: 1.0000),
    Currency(code: 'USD', name: 'Dólar estadounidense', rate: 1.0540),
    Currency(code: 'GBP', name: 'Libra esterlina', rate: 0.8320),
    Currency(code: 'JPY', name: 'Yen japonés', rate: 163.5000),
    Currency(code: 'CHF', name: 'Franco suizo', rate: 0.9350),
    Currency(code: 'CAD', name: 'Dólar canadiense', rate: 1.4800),
    Currency(code: 'AUD', name: 'Dólar australiano', rate: 1.6200),
    Currency(code: 'CNY', name: 'Yuan chino', rate: 7.6300),
    Currency(code: 'MXN', name: 'Peso mexicano', rate: 21.5000),
    Currency(code: 'COP', name: 'Peso colombiano', rate: 4650.0000),
    Currency(code: 'ARS', name: 'Peso argentino', rate: 1050.0000),
    Currency(code: 'BRL', name: 'Real brasileño', rate: 6.1000),
    Currency(code: 'KRW', name: 'Won surcoreano', rate: 1475.0000),
    Currency(code: 'INR', name: 'Rupia india', rate: 89.2000),
    Currency(code: 'SEK', name: 'Corona sueca', rate: 11.5500),
  ];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  late Currency _fromCurrency;
  late Currency _toCurrency;

  @override
  void initState() {
    super.initState();
    _fromCurrency = _staticCurrencies.firstWhere((c) => c.code == 'USD');
    _toCurrency = _staticCurrencies.firstWhere((c) => c.code == 'EUR');
  }

  void _calculate() {
    if (_amountController.text.isEmpty) {
      _resultController.text = "";
      return;
    }

    final double amount =
        double.tryParse(_amountController.text.replaceAll(',', '.')) ?? 0.0;

    final double result =
        (amount / _fromCurrency.rate) * _toCurrency.rate;

    setState(() {
      _resultController.text = result.toStringAsFixed(2);
    });
  }

  String _currencyFlag(String code) {
    const flags = {
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'GBP': '🇬🇧',
      'JPY': '🇯🇵',
      'MXN': '🇲🇽',
      'COP': '🇨🇴',
      'ARS': '🇦🇷',
      'BRL': '🇧🇷',
      'CAD': '🇨🇦',
      'AUD': '🇦🇺',
      'CNY': '🇨🇳',
      'CHF': '🇨🇭',
      'KRW': '🇰🇷',
      'INR': '🇮🇳',
      'SEK': '🇸🇪',
    };
    return flags[code] ?? '';
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
          borderSide: const BorderSide(color: Colors.black, width: 1.8),
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
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 1.4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Currency>(
              value: selected,
              isExpanded: true,
              items: _staticCurrencies.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Row(
                    children: [
                      Text(_currencyFlag(c.code),
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(c.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                      ),
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
                  const Text(
                    'Cambio divisas',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.home_outlined),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/home'),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Importe',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                        border:
                            Border.all(color: Colors.black, width: 1.2),
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

              const Text('Conversión',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _pillTextField(
                controller: _resultController,
                readOnly: true,
                hint: '0.00',
              ),

              const SizedBox(height: 40),

              // LOGO CALCNOW CORRECTO
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

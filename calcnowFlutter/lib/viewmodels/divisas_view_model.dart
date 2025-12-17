import 'package:flutter/material.dart';
import '../models/currency_model.dart';

class DivisasViewModel extends ChangeNotifier {
  final List<Currency> _currencies = [
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

  List<Currency> get currencies => _currencies;

  late Currency _fromCurrency;
  late Currency _toCurrency;
  
  Currency get fromCurrency => _fromCurrency;
  Currency get toCurrency => _toCurrency;
  
  String _result = "";
  String get result => _result;

  DivisasViewModel() {
     _fromCurrency = _currencies.firstWhere((c) => c.code == 'USD');
     _toCurrency = _currencies.firstWhere((c) => c.code == 'EUR');
  }

  void setFromCurrency(Currency c) {
    _fromCurrency = c;
    notifyListeners();
  }
  
  void setToCurrency(Currency c) {
    _toCurrency = c;
    notifyListeners();
  }

  void calculate(String amountStr) {
    if (amountStr.isEmpty) {
      _result = "";
      notifyListeners();
      return;
    }

    final double amount = double.tryParse(amountStr.replaceAll(',', '.')) ?? 0.0;
    final double res = (amount / _fromCurrency.rate) * _toCurrency.rate;
    
    _result = res.toStringAsFixed(2);
    notifyListeners();
  }
}

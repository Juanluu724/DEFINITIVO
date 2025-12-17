import 'dart:math';
import 'package:flutter/material.dart';

class HipotecaViewModel extends ChangeNotifier {
  String _tipoInteres = "fijo";
  String _estadoInmueble = "nuevo";
  String _resultado = "";

  String get tipoInteres => _tipoInteres;
  String get estadoInmueble => _estadoInmueble;
  String get resultado => _resultado;

  void setTipoInteres(String val) {
    _tipoInteres = val;
    notifyListeners();
  }

  void setEstadoInmueble(String val) {
    _estadoInmueble = val;
    notifyListeners();
  }

  void calcular(String precioStr, String ahorroStr, String plazoStr, String interesStr) {
    final precio = double.tryParse(precioStr) ?? 0;
    final ahorro = double.tryParse(ahorroStr) ?? 0;
    final plazo = int.tryParse(plazoStr) ?? 0;
    final interes = double.tryParse(interesStr) ?? 0;

    if (precio <= 0 || plazo <= 0 || interes <= 0) {
      _resultado = "Datos incompletos";
      notifyListeners();
      return;
    }

    final importe = precio - ahorro;
    if (importe <= 0) {
      _resultado = "El ahorro supera el precio";
      notifyListeners();
      return;
    }

    final interesMensual = interes / 100 / 12;
    final cuotas = plazo * 12;

    final cuota = importe *
        interesMensual /
        (1 - (1 / pow(1 + interesMensual, cuotas)));

    _resultado = "${cuota.toStringAsFixed(2)} € / mes";
    notifyListeners();
  }

  void borrarDatos() {
    _tipoInteres = "fijo";
    _estadoInmueble = "nuevo";
    _resultado = "";
    notifyListeners();
  }
}

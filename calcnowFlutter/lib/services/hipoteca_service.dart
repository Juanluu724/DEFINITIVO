import 'dart:convert';
import 'package:http/http.dart' as http;

class HipotecaService {
  static const String baseUrl = String.fromEnvironment(
    'CALCNOW_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, dynamic>> guardarSimulacion({
    required int idUsuario,
    required double monto,
    required double interes,
    required int anios,
    required double cuotaMensual,
    required double totalPagado,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/hipoteca/guardar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_usuario": idUsuario,
        "monto": monto,
        "interes": interes,
        "anios": anios,
        "resultado": {
          "cuota_mensual": cuotaMensual,
          "total_pagado": totalPagado,
        },
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Error backend (${response.statusCode})");
    }

    return jsonDecode(response.body);
  }
}

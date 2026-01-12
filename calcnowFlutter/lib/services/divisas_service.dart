import 'dart:convert';
import 'package:http/http.dart' as http;

class DivisasService {
  static const String baseUrl = String.fromEnvironment(
    'CALCNOW_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, dynamic>> fetchRates({String base = "EUR"}) async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/divisas/rates?base=$base"),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Error backend (${response.statusCode})");
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> guardarTransaccion({
    required int idUsuario,
    required double cantidad,
    required double resultado,
    required String origen,
    required String destino,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/divisas/guardar"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id_usuario": idUsuario,
        "cantidad": cantidad,
        "resultado": resultado,
        "origen": origen,
        "destino": destino,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Error backend (${response.statusCode})");
    }

    return jsonDecode(response.body);
  }
}

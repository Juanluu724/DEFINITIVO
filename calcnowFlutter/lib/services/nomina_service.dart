import 'dart:convert';
import 'package:http/http.dart' as http;

class NominaService {
  static const String baseUrl = String.fromEnvironment(
    'CALCNOW_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, dynamic>> calcularNomina(
      Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/nomina/calcular"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception("Error backend (${response.statusCode})");
    }

    return jsonDecode(response.body);
  }
}

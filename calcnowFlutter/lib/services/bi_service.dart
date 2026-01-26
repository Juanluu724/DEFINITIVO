import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BiService {
  static const String baseUrl = String.fromEnvironment(
    'CALCNOW_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return {};
    return {'Authorization': 'Bearer $token'};
  }

  Future<List<dynamic>> getKpis() => _getList('/api/bi/kpis');
  Future<List<dynamic>> getPopularidad() => _getList('/api/bi/pie');
  Future<List<dynamic>> getHipotecasPorProvincia() => _getList('/api/bi/geo/hip');
  Future<List<dynamic>> getNominasPorProvincia() => _getList('/api/bi/geo/nom');
  Future<List<dynamic>> getDivisasPorMoneda() => _getList('/api/bi/divisas');
  Future<List<dynamic>> getTopHipoteca() => _getList('/api/bi/top/hip');
  Future<List<dynamic>> getTopDivisa() => _getList('/api/bi/top/divisa');
  Future<Uint8List> getPdf() async {
    final uri = Uri.parse('$baseUrl/api/bi/pdf');
    final headers = await _headers();
    final response =
        await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error backend (${response.statusCode})');
    }
    return response.bodyBytes;
  }

  Future<List<dynamic>> _getList(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();
    final response =
        await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error backend (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == true && decoded['data'] is List) {
        return List<dynamic>.from(decoded['data'] as List);
      }
    }
    throw Exception('Formato de respuesta no valido');
  }
}

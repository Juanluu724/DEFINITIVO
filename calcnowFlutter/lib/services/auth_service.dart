import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio de autenticación con manejo básico de errores y timeouts.
class AuthService {
  /// Permite sobreescribir la URL base en build: `--dart-define=CALCNOW_API_BASE_URL=...`
  static const String baseUrl = String.fromEnvironment(
    'CALCNOW_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json'
  };

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) {
    return _post('/auth/login', {"email": email, "password": password});
  }

  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) {
    return _post('/auth/register', {"email": email, "password": password});
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final response = await http
          .post(uri, headers: _jsonHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json;
      }
      return {
        'success': false,
        'message': json['message'] ?? 'Error de servidor (${response.statusCode})',
      };
    } catch (e) {
      return {'success': false, 'message': 'No se pudo conectar con el servidor'};
    }
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _loading = false;
  bool get loading => _loading;

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    _loading = true;
    notifyListeners();

    final response = await AuthService.login(email, password);

    _loading = false;
    notifyListeners();

    if (response["success"] == true || response["ok"] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logged', true);
      final user = response["user"];
      if (user is Map && user["id_usuario"] != null) {
        await prefs.setInt('user_id', user["id_usuario"]);
        await prefs.setBool('is_admin', _asBool(user["es_admin"]));
      }
      final token = response["token"];
      if (token is String && token.isNotEmpty) {
        await prefs.setString('auth_token', token);
      }
    }
    return response;
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(String email, String password, String confirm) async {
     if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      return {"success": false, "message": "Rellena todos los campos"};
    }

    if (password != confirm) {
      return {"success": false, "message": "Las contraseñas no coinciden"};
    }
    
    _loading = true;
    notifyListeners();

    final response = await AuthService.register(email, password);

    _loading = false;
    notifyListeners();
    
    return response;
  }

  bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }
}

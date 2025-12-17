import 'package:flutter/material.dart';
import '../services/nomina_service.dart';

class NominaViewModel extends ChangeNotifier {
  final NominaService _service = NominaService();

  bool _loading = false;
  bool get loading => _loading;

  String pagas = "12";
  String contrato = "General";
  String grupo = "Ingenieros y Licenciados";
  String comunidad = "Andalucía";
  String discapacidad = "Sin discapacidad";
  String estadoCivil = "Soltero";
  bool hijos = false;
  bool conyugeRentas = false;
  bool traslado = false;
  bool dependientes = false;

  void setPagas(String v) { pagas = v; notifyListeners(); }
  void setContrato(String v) { contrato = v; notifyListeners(); }
  void setGrupo(String v) { grupo = v; notifyListeners(); }
  void setComunidad(String v) { comunidad = v; notifyListeners(); }
  void setDiscapacidad(String v) { discapacidad = v; notifyListeners(); }
  void setEstadoCivil(String v) { estadoCivil = v; notifyListeners(); }
  void setHijos(bool v) { hijos = v; notifyListeners(); }
  void setConyugeRentas(bool v) { conyugeRentas = v; notifyListeners(); }
  void setTraslado(bool v) { traslado = v; notifyListeners(); }
  void setDependientes(bool v) { dependientes = v; notifyListeners(); }

  Future<Map<String, dynamic>> calcular(String sueldoStr, String edadStr) async {
    if (sueldoStr.isEmpty || edadStr.isEmpty) {
      throw Exception("Rellena sueldo y edad");
    }

    _loading = true;
    notifyListeners();

    try {
      final data = {
        "salario_bruto_anual": double.parse(sueldoStr),
        "pagas": int.parse(pagas),
        "edad": int.parse(edadStr),
        "grupo": grupo,
        "ubicacion": comunidad,
        "discapacidad": discapacidad,
        "estado_civil": estadoCivil,
        "hijos": hijos ? "Si" : "No",
        "conyuge_rentas_altas": conyugeRentas ? "Si" : "No",
        "traslado_trabajo": traslado ? "Si" : "No",
        "dependientes": dependientes ? "Si" : "No",
        "tipo_contrato": contrato,
      };

      final result = await _service.calcularNomina(data);
      return result;
    } catch (e) {
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

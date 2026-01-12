import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/nomina_service.dart';
import 'refnomina_screen.dart';

class NominaScreen extends StatefulWidget {
  const NominaScreen({super.key});

  @override
  State<NominaScreen> createState() => _NominaScreenState();
}

class _NominaScreenState extends State<NominaScreen> {
  final sueldoCtrl = TextEditingController();
  final edadCtrl = TextEditingController();
  final NominaService _service = NominaService();
  int? _userId;

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

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _userId = prefs.getInt('user_id'));
  }

  Future<void> calcularNomina() async {
    if (sueldoCtrl.text.isEmpty || edadCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rellena sueldo y edad"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => cargando = true);

    try {
      final data = await _service.calcularNomina({
        "sueldo_bruto_anual": double.parse(sueldoCtrl.text),
        "pagas_anuales": int.parse(pagas),
        "edad": int.parse(edadCtrl.text),
        "ubicacion_fiscal": comunidad,
        "grupo_profesional": grupo,
        "grado_discapacidad": _parseDiscapacidad(discapacidad),
        "estado_civil": estadoCivil,
        "hijos": hijos,
        "conyuge_rentas_altas": conyugeRentas,
        "traslado_trabajo": traslado,
        "dependientes": dependientes,
        "tipo_contrato": contrato,
        "id_usuario": _userId,
      });

      final netoMensual =
          double.parse(data["salario_neto_mensual"].toString());
      final irpfMensual = double.parse(data["irpf"].toString());
      final seguridadMensual =
          double.parse(data["seguridad_social"].toString());
      final pagasInt = int.parse(pagas);
      final netoAnual = netoMensual * pagasInt;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RefNominaScreen(
            netoMensual: netoMensual.toStringAsFixed(2),
            pagasExtra:
                (netoAnual / pagasInt).toStringAsFixed(2),
            netoAnual: netoAnual.toStringAsFixed(2),
            retencionAnual:
                (irpfMensual * pagasInt).toStringAsFixed(2),
            tipoRetencion: "15%",
            seguridadSocial:
                (seguridadMensual * pagasInt).toStringAsFixed(2),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al calcular: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text(
                "Calculadora de nómina",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                "Rellena los datos para obtener tu resultado",
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 28),

              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _sectionCard(
                          title: "Datos profesionales",
                          child: Column(
                            children: [
                        campo("Sueldo Bruto Anual", sueldoCtrl),
                        campo("Edad", edadCtrl),
                        dropdown("Número de Pagas", pagas, ["12", "14"],
                            (v) => setState(() => pagas = v)),
                        dropdown("Tipo de contrato", contrato,
                            ["General", "Temporal", "Prácticas"],
                            (v) => setState(() => contrato = v)),
                        dropdown(
                            "Grupo Profesional",
                            grupo,
                            [
                              "Ingenieros y Licenciados",
                              "Ingenieros Técnicos",
                              "Jefes Administrativos",
                              "Oficiales Administrativos",
                              "Auxiliares",
                              "Subalternos"
                            ],
                            (v) => setState(() => grupo = v)),
                        botonesSiNo(
                            "¿Traslado por trabajo?",
                            traslado,
                            (v) => setState(() => traslado = v)),
                            ],
                          ),
                        ),
                      ),

                  const SizedBox(width: 28),

                      Expanded(
                        child: _sectionCard(
                          title: "Datos personales",
                          child: Column(
                            children: [
                        dropdown(
                            "Ubicación del domicilio fiscal",
                            comunidad,
                            [
                              "Andalucía",
                              "Madrid",
                              "Cataluña",
                              "Valencia",
                              "País Vasco"
                            ],
                            (v) => setState(() => comunidad = v)),
                        dropdown(
                            "Discapacidad",
                            discapacidad,
                            [
                              "Sin discapacidad",
                              "33% o más",
                              "65% o más"
                            ],
                            (v) => setState(() => discapacidad = v)),
                        dropdown("Estado civil", estadoCivil,
                            ["Soltero", "Casado"],
                            (v) => setState(() => estadoCivil = v)),
                        botonesSiNo(
                            "¿Cónyuge con rentas > 1500€?",
                            conyugeRentas,
                            (v) => setState(() => conyugeRentas = v)),
                        botonesSiNo("¿Tienes hijos?",
                            hijos, (v) => setState(() => hijos = v)),
                        botonesSiNo(
                            "¿Personas a tu cargo?",
                            dependientes,
                            (v) => setState(() => dependientes = v)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: cargando ? null : calcularNomina,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077CC),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                ),
                child: cargando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Calcular",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
              ),

              const SizedBox(height: 40),

              
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

  // ---------- COMPONENTES ----------
  Widget campo(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF0077CC), width: 2),
          ),
        ),
      ),
    );
  }

  Widget dropdown(String label, String value, List<String> items,
      Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<String>(
        value: value,
        items:
            items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v!),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.black, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF0077CC), width: 2),
          ),
        ),
      ),
    );
  }

  Widget botonesSiNo(
      String texto, bool valor, Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(texto,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              boton("Sí", valor, () => onChange(true)),
              const SizedBox(width: 12),
              boton("No", !valor, () => onChange(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget boton(String texto, bool activo, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF0077CC) : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black),
          boxShadow: activo
              ? const [
                  BoxShadow(
                    color: Color(0x330077CC),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Text(
          texto,
          style: TextStyle(
              color: activo ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  double _parseDiscapacidad(String value) {
    if (value.contains("65")) return 65;
    if (value.contains("33")) return 33;
    return 0;
  }
}

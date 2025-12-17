import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'refnomina_screen.dart';

class NominaScreen extends StatefulWidget {
  const NominaScreen({super.key});

  @override
  State<NominaScreen> createState() => _NominaScreenState();
}

class _NominaScreenState extends State<NominaScreen> {
  final sueldoCtrl = TextEditingController();
  final edadCtrl = TextEditingController();

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
      final response = await http.post(
        Uri.parse("http://localhost:3000/api/nomina/calcular"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "salario_bruto_anual": double.parse(sueldoCtrl.text),
          "pagas": int.parse(pagas),
          "edad": int.parse(edadCtrl.text),
          "grupo": grupo,
          "ubicacion": comunidad,
          "discapacidad": discapacidad,
          "estado_civil": estadoCivil,
          "hijos": hijos ? "Si" : "No",
          "conyuge_rentas_altas": conyugeRentas ? "Si" : "No",
          "traslado_trabajo": traslado ? "Si" : "No",
          "dependientes": dependientes ? "Si" : "No",
          "tipo_contrato": contrato,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Error backend");
      }

      final data = jsonDecode(response.body);
      final netoAnual =
          double.parse(data["salario_neto_anual"].toString());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RefNominaScreen(
            netoMensual: data["salario_neto_mensual"],
            pagasExtra:
                (netoAnual / int.parse(pagas)).toStringAsFixed(2),
            netoAnual: data["salario_neto_anual"],
            retencionAnual: data["retencion_anual"],
            tipoRetencion: "15%",
            seguridadSocial: data["seguridad_social"],
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
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text(
                "Calculadora de nómina",
                style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 40),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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

                  const SizedBox(width: 80),

                  Expanded(
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
                ],
              ),

              const SizedBox(height: 40),

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
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
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
}

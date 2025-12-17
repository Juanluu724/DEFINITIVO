import 'package:flutter/material.dart';

class RefNominaScreen extends StatelessWidget {
  final String netoMensual;
  final String pagasExtra;
  final String netoAnual;
  final String retencionAnual;
  final String tipoRetencion;
  final String seguridadSocial;

  const RefNominaScreen({
    super.key,
    required this.netoMensual,
    required this.pagasExtra,
    required this.netoAnual,
    required this.retencionAnual,
    required this.tipoRetencion,
    required this.seguridadSocial,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: SafeArea(
        child: Stack(
          children: [
            // ---------------- ICONO HOME ----------------
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () =>
                    Navigator.pushReplacementNamed(context, "/home"),
                child: const Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Text(
                      "Resultado de la nómina",
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 60),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---------------- IZQUIERDA ----------------
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titulo("Tu sueldo mensual neto sería de"),
                            cajaResultado(netoMensual),

                            const SizedBox(height: 40),

                            titulo("Tendrías 2 pagas extra de"),
                            cajaResultado(pagasExtra),

                            const SizedBox(height: 40),

                            titulo("Equivalente a un sueldo anual neto de"),
                            cajaResultado(netoAnual),
                          ],
                        ),

                        const SizedBox(width: 90),

                        // ---------------- DERECHA ----------------
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titulo("Retención de IRPF anual"),
                            cajaResultado(retencionAnual),

                            const SizedBox(height: 40),

                            titulo("Tipo de retención"),
                            cajaResultado(tipoRetencion),

                            const SizedBox(height: 40),

                            titulo("Cuotas de la Seguridad Social al año"),
                            cajaResultado(seguridadSocial),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // ---------------- BOTÓN REPETIR ----------------
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, "/nomina"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077CC),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      child: const Text(
                        "Repetir cálculo",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // 
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
          ],
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------

  Widget titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget cajaResultado(String valor) {
    return Container(
      width: 320,
      height: 55,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black, width: 2.5),
      ),
      alignment: Alignment.center,
      child: Text(
        valor,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _hovered = ""; // Para detectar hover
  String _pressed = ""; // Para animacion de rebote al hacer clic
  bool _biEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadBiAccess();
  }

  Future<void> _loadBiAccess() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _biEnabled = prefs.getBool('is_admin') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://images.pexels.com/photos/6757559/pexels-photo-6757559.jpeg?auto=compress&cs=tinysrgb&h=627&fit=crop&w=1200',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 160,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
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
                  const SizedBox(height: 110),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 90,
                    runSpacing: 90,
                    children: [
                      _buildCard(
                        title: "Cambio de divisas",
                        description:
                            "Convierte monedas al instante\ncon tasas actualizadas.",
                        onTap: () => Navigator.pushNamed(context, '/divisas'),
                      ),
                      _buildCard(
                        title: "Calculo de nomina",
                        description:
                            "Calcula tu salario neto de forma\nrapida y precisa.",
                        onTap: () => Navigator.pushNamed(context, '/nomina'),
                      ),
                      _buildCard(
                        title: "Calculo de hipoteca",
                        description: "Simula tu cuota mensual en\nsegundos.",
                        onTap: () => Navigator.pushNamed(context, '/hipoteca'),
                      ),
                      if (_biEnabled)
                        _buildCard(
                          title: "Inteligencia de mercado",
                          description:
                              "KPIs y tendencias\ncon datos reales.",
                          onTap: () => Navigator.pushNamed(context, '/bi'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 130),
                  SizedBox(
                    width: 280,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final bool isHovered = _hovered == title;
    final bool isPressed = _pressed == title;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = title),
      onExit: (_) => setState(() => _hovered = ""),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = title),
        onTapUp: (_) {
          Future.delayed(const Duration(milliseconds: 120), () {
            setState(() => _pressed = "");
          });
          onTap();
        },
        onTapCancel: () => setState(() => _pressed = ""),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..scale(isPressed
                ? 0.95
                : isHovered
                    ? 1.08
                    : 1.0),
          width: 340,
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 45),
          decoration: BoxDecoration(
            color: const Color(0xFF083D5D),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isHovered ? 0.45 : 0.25),
                blurRadius: isHovered ? 30 : 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 40),
              const Icon(
                Icons.touch_app_outlined,
                color: Colors.white,
                size: 38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

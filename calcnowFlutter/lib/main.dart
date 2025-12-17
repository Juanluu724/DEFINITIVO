import 'package:flutter/material.dart';

// -------------------- VISTAS --------------------
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/home/home_screen.dart';

// -------------------- CALCULADORAS --------------------
import 'views/nomina/nomina_screen.dart';
import 'views/hipoteca/hipoteca_screen.dart';
import 'views/divisas/divisas_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalcNowApp());
}

class CalcNowApp extends StatelessWidget {
  const CalcNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalcNow',

      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF46899F),
        scaffoldBackgroundColor: const Color(0xFFEEF3F8),
        fontFamily: 'Poppins',
      ),

      // Pantalla inicial
      home: const HomeScreen(),

      // ---------------- RUTAS ----------------
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),

        // --------- CALCULADORAS ---------
        '/nomina': (context) => NominaScreen(),
        '/hipoteca': (context) => const HipotecaScreen(),
        '/divisas': (context) => const DivisasScreen(),},
    );
  }
}

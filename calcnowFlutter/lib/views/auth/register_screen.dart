import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _hide1 = true;
  bool _hide2 = true;
  bool _loading = false;

  Future<void> _registrar() async {
    final email = _email.text.trim();
    final pass = _pass.text.trim();
    final confirm = _confirm.text.trim();

    if (email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _alert("Rellena todos los campos");
      return;
    }

    if (pass != confirm) {
      _alert("Las contrasenas no coinciden");
      return;
    }

    setState(() => _loading = true);
    final response = await AuthService.register(email, pass);
    setState(() => _loading = false);

    if (response["success"] == true) {
      _alert("Cuenta creada con exito");
      if (mounted) Navigator.pop(context);
    } else {
      _alert(response["message"] ?? "Error en el registro");
    }
  }

  void _alert(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F8),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 25,
              right: 25,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/home'),
                child: const Icon(
                  Icons.home_outlined,
                  size: 40,
                  color: Colors.black87,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    const SizedBox(height: 35),
                    const Text(
                      "Registrate",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Crea tu cuenta de CalcNow",
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 370,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Correo electronico"),
                          const SizedBox(height: 6),
                          _buildInput(_email),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 370,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Crea una contrasena"),
                          const SizedBox(height: 6),
                          _buildInput(
                            _pass,
                            obscure: _hide1,
                            toggle: () => setState(() => _hide1 = !_hide1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: 370,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Confirmar contrasena"),
                          const SizedBox(height: 6),
                          _buildInput(
                            _confirm,
                            obscure: _hide2,
                            toggle: () => setState(() => _hide2 = !_hide2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 45),
                    SizedBox(
                      width: 230,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "CALC",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "NOW",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF46899F),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          "assets/logo_transparente.png",
                          width: 55,
                          height: 55,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller, {
    bool obscure = false,
    VoidCallback? toggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        suffixIcon: toggle != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black87,
                ),
                onPressed: toggle,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF46899F),
            width: 2.7,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF46899F),
            width: 3.2,
          ),
        ),
      ),
    );
  }
}

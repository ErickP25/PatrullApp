import 'package:flutter/material.dart';
import '../widgets/boton_primario.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import '../models/usuario.dart';

class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final _dniController = TextEditingController();
  final _claveController = TextEditingController();

  String? _errorMsg;
  bool _loading = false;
  final AuthService _authService = AuthService(
    baseUrl: "http://192.168.100.46:5000",
  );

  Future<void> _iniciarSesion() async {
    setState(() {
      _errorMsg = null;
      _loading = true;
    });

    try {
      final usuarioData = await _authService.login(
        _dniController.text.trim(),
        _claveController.text.trim(),
      );

      // Si tu backend retorna usuario completo:
      final usuario = Usuario.fromJson(usuarioData['usuario'] ?? usuarioData);

      if (!mounted) return;
      setState(() => _loading = false);

      // Navega y pasa el usuario o simplemente redirige
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/inicio',
        (_) => false,
        arguments: usuario.id, // O usuario.id_usuario según tu modelo
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMsg = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  @override
  void dispose() {
    _dniController.dispose();
    _claveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo_patrullapp.png",
                width: 145,
                height: 100,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 19),
              const Text(
                "Bienvenido a PatrullApp",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: AppColors.azulPrincipal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: _dniController,
                decoration: InputDecoration(
                  labelText: "DNI",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(
                    Icons.badge,
                    color: AppColors.azulPrincipal,
                  ),
                  errorText: _errorMsg != null ? "" : null,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _claveController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.azulPrincipal,
                  ),
                  errorText: _errorMsg != null ? "" : null,
                ),
                obscureText: true,
              ),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 7, bottom: 4),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              const SizedBox(height: 13),
              BotonPrimario(
                texto: "Iniciar Sesión",
                cargando: _loading,
                onPressed: _loading ? () {} : _iniciarSesion, // Cambio aquí
              ),
              const SizedBox(height: 19),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registro');
                },
                child: Text(
                  "¿No tienes cuenta? Regístrate",
                  style: const TextStyle(
                    color: AppColors.azulPrincipal,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

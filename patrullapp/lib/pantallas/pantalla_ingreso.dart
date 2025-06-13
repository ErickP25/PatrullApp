import 'package:flutter/material.dart';
import '../widgets/boton_primario.dart';
import '../utils/colors.dart';

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

  void _iniciarSesion() async {
    setState(() {
      _errorMsg = null;
      _loading = true;
    });

    // Simula validación (reemplaza esto por tu backend)
    await Future.delayed(const Duration(seconds: 2));

    final dni = _dniController.text.trim();
    final clave = _claveController.text.trim();

    // Simulación: solo permite dni="78546221" y clave="vegueta777"
    if (dni == "78546221" && clave == "vegueta777") {
      setState(() => _loading = false);
      // Navega a inicio (y borra el stack para que no regrese atrás)
      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (_) => false);
    } else {
      setState(() {
        _loading = false;
        _errorMsg = "DNI o Contraseña Incorrecto";
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
              // LOGO DE TU APP
              Image.asset(
                "assets/logo_patrullapp.png", // Usa el nombre de tu archivo real
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
              // DNI
              TextField(
                controller: _dniController,
                decoration: InputDecoration(
                  labelText: "DNI",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  errorText: _errorMsg != null
                      ? ""
                      : null, // para mostrar el mensaje debajo
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Contraseña
              TextField(
                controller: _claveController,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  errorText: _errorMsg != null ? "" : null,
                ),
                obscureText: true,
              ),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
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
              // Botón Iniciar Sesión
              BotonPrimario(
                texto: "Iniciar Sesión",
                cargando: _loading,
                onPressed: _iniciarSesion,
              ),
              const SizedBox(height: 19),
              // Enlace a registro
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registro');
                },
                child: Text(
                  "¿No tienes cuenta? Regístrate",
                  style: TextStyle(
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

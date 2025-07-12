import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/registro_service.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final apellidoController = TextEditingController();
  final dniController = TextEditingController();
  final telefonoController = TextEditingController();
  final direccionController = TextEditingController();
  final contrasenaController = TextEditingController();
  final RegistroService _registroService = RegistroService(
    baseUrl: "http://192.168.1.220:5000",
  ); // Actualiza IP si es necesario

  bool _cargando = false;
  String? _error;

  void _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resp = await _registroService.registrarVecino({
        'nombre': nombreController.text.trim(),
        'apellido': apellidoController.text.trim(),
        'dni': dniController.text.trim(),
        'telefono': telefonoController.text.trim(),
        'direccion': direccionController.text.trim(),
        'contrasena': contrasenaController.text,
      });
      // Registro exitoso
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Text("¡Registro Exitoso!"),
            content: Text(
              "Bienvenido/a, ${resp['nombre'] ?? ''}.\nAhora puedes iniciar sesión.",
              style: const TextStyle(fontSize: 17),
            ),
            actions: [
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pushReplacementNamed('/ingreso');
                },
                label: const Text("Ir al login"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception:', '').trim());
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Registro de Vecino',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        backgroundColor: AppColors.azulPrincipal,
      ),
      body: Stack(
        children: [
          if (_cargando) const Center(child: CircularProgressIndicator()),
          IgnorePointer(
            ignoring: _cargando,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  // Tarjeta blanca con sombra
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22,
                      horizontal: 18,
                    ),
                    margin: const EdgeInsets.only(top: 20, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          campoInput(
                            controller: nombreController,
                            label: "Nombre",
                            icono: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                          campoInput(
                            controller: apellidoController,
                            label: "Apellido",
                            icono: Icons.person,
                          ),
                          const SizedBox(height: 12),
                          campoInput(
                            controller: dniController,
                            label: "DNI",
                            icono: Icons.badge_outlined,
                            keyboard: TextInputType.number,
                            maxLen: 8,
                            validator: (v) => v == null || v.length != 8
                                ? 'Debe tener 8 dígitos'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          campoInput(
                            controller: telefonoController,
                            label: "Teléfono",
                            icono: Icons.phone_android,
                            keyboard: TextInputType.phone,
                            maxLen: 9,
                            validator: (v) => v == null || v.length < 7
                                ? 'Número inválido'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          campoInput(
                            controller: direccionController,
                            label: "Dirección",
                            icono: Icons.home_outlined,
                          ),
                          const SizedBox(height: 12),
                          campoInput(
                            controller: contrasenaController,
                            label: "Contraseña",
                            icono: Icons.lock_outline,
                            isPassword: true,
                            validator: (v) => v == null || v.length < 6
                                ? 'Mínimo 6 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          const SizedBox(height: 2),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.person_add_alt_1,
                                size: 24,
                              ),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                child: Text(
                                  "Registrarse",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.azulPrincipal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                              ),
                              onPressed: _registrar,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Info extra
                  const SizedBox(height: 10),
                  const Text(
                    "¿Ya tienes cuenta? Inicia sesión desde el login.",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget campoInput({
    required TextEditingController controller,
    required String label,
    required IconData icono,
    TextInputType? keyboard,
    bool isPassword = false,
    int? maxLen,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      obscureText: isPassword,
      maxLength: maxLen,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, color: AppColors.azulPrincipal),
        filled: true,
        fillColor: AppColors.grisFondo.withOpacity(0.13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13)),
        counterText: "",
      ),
      validator:
          validator ?? (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
    );
  }
}

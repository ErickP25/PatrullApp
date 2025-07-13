import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/perfil_service.dart';
import '../utils/colors.dart';

class PantallaCambiarPassword extends StatefulWidget {
  const PantallaCambiarPassword({super.key});

  @override
  State<PantallaCambiarPassword> createState() => _PantallaCambiarPasswordState();
}

class _PantallaCambiarPasswordState extends State<PantallaCambiarPassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  bool _cargando = false;

  Future<void> _cambiarPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('id_usuario');
      await PerfilService(baseUrl: "http://192.168.1.219:5000").cambiarPassword(
        idUsuario!,
        _oldPwdCtrl.text,
        _newPwdCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña cambiada correctamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cambiar contraseña"),
        backgroundColor: AppColors.azulPrincipal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldPwdCtrl,
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _newPwdCtrl,
                decoration: const InputDecoration(labelText: 'Nueva contraseña'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 30),
              _cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                          minimumSize: const Size.fromHeight(45)),
                      onPressed: _cambiarPassword,
                      child: const Text("Cambiar contraseña"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PantallaRegistro extends StatelessWidget {
  const PantallaRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 Registro')),
      body: const Center(
        child: Text('Formulario para registrar un nuevo usuario.'),
      ),
    );
  }
}

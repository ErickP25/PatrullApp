import 'package:flutter/material.dart';

class PantallaRutasSereno extends StatelessWidget {
  const PantallaRutasSereno({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛡️ Rutas del Sereno')),
      body: const Center(
        child: Text('Aquí se mostrarán las rutas asignadas.'),
      ),
    );
  }
}

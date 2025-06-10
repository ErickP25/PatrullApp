import 'package:flutter/material.dart';

class PantallaMapaZonas extends StatelessWidget {
  const PantallaMapaZonas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗺️ Mapa de Zonas')),
      body: const Center(
        child: Text('Aquí se visualizarán zonas peligrosas.'),
      ),
    );
  }
}

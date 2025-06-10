import 'package:flutter/material.dart';

class PantallaAlerta extends StatelessWidget {
  const PantallaAlerta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🚨 Alerta de Emergencia')),
      body: const Center(
        child: Text('Aquí podrás enviar alertas urgentes.'),
      ),
    );
  }
}

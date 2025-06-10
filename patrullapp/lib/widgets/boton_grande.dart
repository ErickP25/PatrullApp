import 'package:flutter/material.dart';

class BotonGrande extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  final VoidCallback onTap;
  final bool cargando;

  const BotonGrande({
    super.key,
    required this.icono,
    required this.color,
    required this.texto,
    required this.onTap,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(60),
      onTap: cargando ? null : onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          shape: BoxShape.circle,
        ),
        child: cargando
            ? const Center(child: CircularProgressIndicator())
            : Icon(icono, color: color, size: 48),
      ),
    );
  }
}

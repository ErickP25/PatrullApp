import 'package:flutter/material.dart';
import '../utils/colors.dart';

class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;
  final bool cargando;

  const BotonPrimario({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulPrincipal,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: cargando
            ? const SizedBox(
                width: 25, height: 25,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              )
            : Text(texto),
      ),
    );
  }
}

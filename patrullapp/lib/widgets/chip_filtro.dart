import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const ChipFiltro({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.azulPrincipal : AppColors.grisBoton,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: seleccionado ? Colors.white : AppColors.textoOscuro,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

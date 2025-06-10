import 'package:flutter/material.dart';
import '../utils/colors.dart';

class BarraNav extends StatelessWidget {
  final int indiceActual;
  final Function(int)? onTap;

  const BarraNav({super.key, required this.indiceActual, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: indiceActual,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Principal'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Mis reportes'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
      selectedItemColor: AppColors.azulPrincipal,
      unselectedItemColor: AppColors.textoOscuro,
      backgroundColor: Colors.white,
      showUnselectedLabels: true,
    );
  }
}

import 'package:flutter/material.dart';

class BadgeReputacion extends StatelessWidget {
  final String reputacion;
  final VoidCallback onTap;

  const BadgeReputacion({
    super.key,
    required this.reputacion,
    required this.onTap,
  });

  Color get color {
    // Puedes ajustar colores según reputación real
    if (reputacion.toLowerCase().contains('buena')) {
      return const Color(0xFF2ECC40); // Verde
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.16),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_user, color: color, size: 18),
            const SizedBox(width: 7),
            Text(
              reputacion,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.info_outline, color: color, size: 17),
          ],
        ),
      ),
    );
  }
}

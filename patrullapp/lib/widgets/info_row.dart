import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String contenido;

  const InfoRow({
    super.key,
    required this.icono,
    required this.titulo,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.grey[700], size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  contenido,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

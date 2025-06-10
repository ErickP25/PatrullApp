import 'package:flutter/material.dart';

class PerfilInfoRow extends StatelessWidget {
  final IconData icono;
  final String texto;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PerfilInfoRow({
    super.key,
    required this.icono,
    required this.texto,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icono, color: Colors.grey[700]),
      title: Text(texto, style: const TextStyle(fontSize: 16)),
      trailing: trailing,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      minLeadingWidth: 0,
      dense: true,
    );
  }
}

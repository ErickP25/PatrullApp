import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TooltipInfo extends StatelessWidget {
  final String texto;
  final VoidCallback onClose;
  const TooltipInfo({super.key, required this.texto, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 32,
      right: 32,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.azulClaro,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 8,
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.azulPrincipal),
              const SizedBox(width: 12),
              Expanded(child: Text(texto, style: const TextStyle(fontSize: 14))),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
              )
            ],
          ),
        ),
      ),
    );
  }
}

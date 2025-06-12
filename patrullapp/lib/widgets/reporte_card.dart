/*
import 'package:flutter/material.dart';
import '../models/reporte.dart';
import '../utils/colors.dart';

class ReporteCard extends StatelessWidget {
  final Reporte reporte;
  final VoidCallback onFavorito;
  final VoidCallback onEliminar;
  final VoidCallback onVerMapa;
  final VoidCallback? onTap;
  const ReporteCard({
    super.key,
    required this.reporte,
    required this.onFavorito,
    required this.onEliminar,
    required this.onVerMapa,
    this.onTap,
  });

  Color getColorEstado(String estado) {
    switch (estado) {
      case "Atendido":
        return AppColors.azulPrincipal;
      case "Falsa alarma":
        return AppColors.rojoAlerta;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Favorito
              IconButton(
                icon: Icon(
                  reporte.favorito ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: reporte.favorito ? Colors.amber : Colors.grey,
                ),
                onPressed: onFavorito,
              ),
              const SizedBox(width: 2),
              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reporte.tipo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(reporte.direccion, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    const SizedBox(height: 3),
                    Text(
                      "Hace ${_tiempoDesde(reporte.fecha)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: getColorEstado(reporte.estado).withOpacity(0.11),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  reporte.estado,
                  style: TextStyle(
                    color: getColorEstado(reporte.estado),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Menú contextual
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline, color: Colors.red, size: 19),
                        SizedBox(width: 8),
                        Text("Eliminar"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'favorito',
                    child: Row(
                      children: const [
                        Icon(Icons.star_outline, color: Colors.amber, size: 19),
                        SizedBox(width: 8),
                        Text("Guardar como favorito"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'vermapa',
                    child: Row(
                      children: const [
                        Icon(Icons.map_outlined, color: AppColors.azulPrincipal, size: 19),
                        SizedBox(width: 8),
                        Text("Ver en mapa"),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'eliminar':
                      onEliminar();
                      break;
                    case 'favorito':
                      onFavorito();
                      break;
                    case 'vermapa':
                      onVerMapa();
                      break;
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _tiempoDesde(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inHours < 1) {
      return "${diff.inMinutes} min";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} h";
    } else if (diff.inDays == 1) {
      return "1 día";
    } else {
      return "${diff.inDays} días";
    }
  }
}*/

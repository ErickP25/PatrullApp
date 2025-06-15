import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/info_row.dart';
import '../models/reporte_mock.dart';
import '../utils/colors.dart';

class PantallaDetalleReporte extends StatelessWidget {
  final Reporte reporte;

  const PantallaDetalleReporte({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Detalles",
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoOscuro),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              reporte.favorito ? Icons.star : Icons.star_border,
              color: reporte.favorito ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              // Aquí lógica de guardar como favorito
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Funcionalidad favorito en desarrollo")),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.azulPrincipal,
            ),
            onPressed: () {
              // Aquí lógica para compartir o copiar link
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Funcionalidad compartir en desarrollo"),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        children: [
          // Título del reporte
          Text(
            reporte.tipo,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: AppColors.azulPrincipal,
            ),
          ),
          const SizedBox(height: 16),

          // Fecha y hora
          InfoRow(
            icono: Icons.calendar_today,
            titulo: "Fecha y hora del reporte:",
            contenido:
                "Reportado el ${_fechaFormateada(reporte.fecha)} a las ${_horaFormateada(reporte.fecha)}",
          ),

          // Ubicación
          InfoRow(
            icono: Icons.place_outlined,
            titulo: "Ubicación del hecho:",
            contenido: reporte.direccion,
          ),

          // Descripción
          InfoRow(
            icono: Icons.text_snippet_outlined,
            titulo: "Descripción:",
            contenido:
                "Dos sujetos a bordo de una motocicleta interceptaron a un transeúnte y le arrebataron su teléfono celular. Luego huyeron con dirección hacia Av. México.",
          ),

          // Prioridad
          InfoRow(
            icono: Icons.flag_outlined,
            titulo: "Prioridad:",
            contenido: "Nivel 3",
          ),

          // Estado del reporte
          InfoRow(
            icono: Icons.verified_outlined,
            titulo: "Estado del reporte:",
            contenido: reporte.estado == "En espera"
                ? "En atención"
                : reporte.estado,
          ),

          // Atendido por
          InfoRow(
            icono: Icons.security_outlined,
            titulo: "Atendido por:",
            contenido: "Patrulla 14 – Sereno C. Mendoza",
          ),

          // Tiempo de respuesta
          InfoRow(
            icono: Icons.timer_outlined,
            titulo: "Tiempo de respuesta:",
            contenido: "8 minutos",
          ),
        ],
      ),
      bottomNavigationBar: BarraNav(
        indiceActual: 1, // Porque viene desde Mis Reportes
        onTap: (nuevoIndice) {
          if (nuevoIndice == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/inicio', (_) => false);
          }
          if (nuevoIndice == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/historial',
              (_) => false,
            );
          }
          if (nuevoIndice == 2) {
            Navigator.pushNamedAndRemoveUntil(context, '/perfil', (_) => false);
          }
        },
      ),
    );
  }

  String _fechaFormateada(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}";
  }

  String _horaFormateada(DateTime fecha) {
    return "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }
}

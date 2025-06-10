import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../widgets/navbar.dart';
import '../widgets/boton_grande.dart';
import '../widgets/tooltip_info.dart';

enum EstadoGrabacion { inicio, grabando, revisando, tooltip }

class PantallaReporte extends StatefulWidget {
  const PantallaReporte({super.key});

  @override
  State<PantallaReporte> createState() => _PantallaReporteState();
}

class _PantallaReporteState extends State<PantallaReporte> {
  EstadoGrabacion estado = EstadoGrabacion.inicio;
  bool tooltipActivo = false;
  String ubicacion = "Av. La Marina 553";
  String evidencia = "";
  String transcripcion = "";

  // Simulación de evidencia y transcripción
  void _iniciarGrabacion() {
    setState(() {
      estado = EstadoGrabacion.grabando;
      tooltipActivo = false;
      transcripcion = "";
    });
    // Aquí iría la lógica de grabar audio
  }

  void _detenerGrabacion() {
    setState(() {
      estado = EstadoGrabacion.revisando;
      transcripcion = '"Un sujeto armado acaba de robar una moto en la Av. La Marina, cuadra 12"'; // Simulación
    });
  }

  void _mostrarTooltip() {
    setState(() => tooltipActivo = true);
  }

  void _ocultarTooltip() {
    setState(() => tooltipActivo = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.grisFondo,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textoOscuro),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Nuevo Incidente', style: TextStyle(color: AppColors.textoOscuro)),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sección de ubicación
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 18, top: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.place_outlined, color: AppColors.azulPrincipal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(ubicacion,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                // Estado de grabación o transcripción
                if (estado == EstadoGrabacion.inicio) ...[
                  Center(
                    child: Column(
                      children: [
                        BotonGrande(
                          icono: Icons.mic,
                          color: AppColors.rojoAlerta,
                          texto: "",
                          onTap: _iniciarGrabacion,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Describir incidente por voz",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _mostrarTooltip,
                              child: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (estado == EstadoGrabacion.grabando) ...[
                  Center(
                    child: Column(
                      children: [
                        BotonGrande(
                          icono: Icons.stop_rounded,
                          color: AppColors.rojoAlerta,
                          texto: "",
                          onTap: _detenerGrabacion,
                          cargando: false, // O usa true si quieres animación
                        ),
                        const SizedBox(height: 10),
                        const Text("Grabando...",
                            style: TextStyle(color: AppColors.rojoAlerta, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ] else ...[
                  // Estado de revisión
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.azulClaro,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline, size: 36, color: AppColors.azulPrincipal),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("00:12", style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 6),
                              Text(transcripcion, style: const TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () {}, // Lógica para editar texto
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text("Resumen:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text("Tipo de incidente:", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      Text("Robo", style: TextStyle(fontWeight: FontWeight.w400)),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text("Referencia:", style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          "Frente a la pollería Roky’s de la Av. Universitaria con Los Alisos",
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () {},
                      )
                    ],
                  ),
                ],

                // Botón subir evidencia
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textoOscuro,
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: AppColors.azulPrincipal, width: 1.2),
                    ),
                    onPressed: () {}, // Lógica para subir evidencia
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text("Subir evidencia"),
                  ),
                ),

                // Botones finales
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                          minimumSize: const Size(0, 48),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        onPressed: () {}, // Lógica para enviar reporte
                        child: const Text("Enviar Reporte"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.grisBoton,
                          foregroundColor: Colors.grey,
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: const BarraNav(indiceActual: 0),
        ),
        // Tooltip info
        if (tooltipActivo)
          TooltipInfo(
            texto: "Al hablar, el sistema convertirá automáticamente tu mensaje en texto usando IA. Luego podrás revisar el resumen antes de enviarlo.",
            onClose: _ocultarTooltip,
          ),
      ],
    );
  }
}

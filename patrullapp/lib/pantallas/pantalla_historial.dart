/*
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/reporte_card.dart';
import '../models/reporte.dart';
import '../utils/colors.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  int _indiceNav = 1; // Mis reportes es el tab 1

  // Filtros de ejemplo
  List<String> tipos = ["Tipo incidente", "Estado", "Fecha"];
  int filtroActivo = 0;

  // Lista de reportes (ejemplo, luego lo conectas a tu backend)
  List<Reporte> reportes = [
    Reporte(
      id: "1",
      tipo: "Robo al paso",
      direccion: "Jr. Renovación con Av. Isabel La Católica, La Victoria",
      fecha: DateTime.now().subtract(const Duration(minutes: 15)),
      estado: "En espera",
    ),
    Reporte(
      id: "2",
      tipo: "Acoso callejero",
      direccion: "Parque Cánepa, La Victoria",
      fecha: DateTime.now().subtract(const Duration(hours: 1)),
      estado: "Atendido",
    ),
    Reporte(
      id: "3",
      tipo: "Riña entre pandillas",
      direccion: "Mercado San Cosme, La Victoria",
      fecha: DateTime.now().subtract(const Duration(hours: 2)),
      estado: "Falsa alarma",
    ),
    Reporte(
      id: "4",
      tipo: "Sospecha de merodeo nocturno",
      direccion: "Calle Antonio Raimondi, Santa Anita",
      fecha: DateTime.now().subtract(const Duration(hours: 4)),
      estado: "Atendido",
    ),
    Reporte(
      id: "5",
      tipo: "Robo a comercio",
      direccion: "Mercado San Cosme, La Victoria",
      fecha: DateTime.now().subtract(const Duration(days: 1)),
      estado: "Atendido",
    ),
  ];

  void _onNavTap(int i) {
    setState(() => _indiceNav = i);
    if (i == 0) Navigator.pushNamedAndRemoveUntil(context, '/inicio', (_) => false);
    if (i == 2) Navigator.pushNamedAndRemoveUntil(context, '/perfil', (_) => false);
  }

  void _onEliminar(Reporte r) {
    setState(() {
      reportes.removeWhere((rep) => rep.id == r.id);
    });
  }

  void _onFavorito(Reporte r) {
    setState(() {
      int idx = reportes.indexWhere((rep) => rep.id == r.id);
      if (idx >= 0) {
        reportes[idx] = Reporte(
          id: r.id,
          tipo: r.tipo,
          direccion: r.direccion,
          fecha: r.fecha,
          estado: r.estado,
          favorito: !r.favorito,
        );
      }
    });
  }

  void _onVerMapa(Reporte r) {
    // Lógica para ver ubicación en mapa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ver en mapa: ${r.direccion}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Mis Reportes", style: TextStyle(color: AppColors.textoOscuro)),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              // Filtro avanzado
            },
            icon: const Icon(Icons.filter_alt_outlined, color: AppColors.azulPrincipal),
            label: const Text("Filtrar por", style: TextStyle(color: AppColors.azulPrincipal)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chips de filtro
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: List.generate(
                tipos.length,
                (i) => ChipFiltro(
                  label: tipos[i],
                  seleccionado: filtroActivo == i,
                  onTap: () => setState(() => filtroActivo = i),
                ),
              ),
            ),
          ),
          // Lista de reportes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              itemCount: reportes.length,
              itemBuilder: (context, i) {
                final reporte = reportes[i];
                return ReporteCard(
                  reporte: reporte,
                  onFavorito: () => _onFavorito(reporte),
                  onEliminar: () => _onEliminar(reporte),
                  onVerMapa: () => _onVerMapa(reporte),
                  onTap: () {
                    // ¡Aquí va la navegación con argumentos!
                    Navigator.pushNamed(
                      context,
                      '/detalle',
                      arguments: reporte, // <--- ¡ESTO ES LO NUEVO!
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraNav(
        indiceActual: _indiceNav,
        onTap: _onNavTap,
      ),
    );
  }
}
*/
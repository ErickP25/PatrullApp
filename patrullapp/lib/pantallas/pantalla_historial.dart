import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- asegúrate de instalar el paquete
import '../widgets/navbar.dart';
import '../widgets/chip_filtro.dart';
import '../widgets/reporte_card.dart';
import '../models/reporte.dart';
import '../utils/colors.dart';
import '../services/reporte_service.dart';

class PantallaHistorial extends StatefulWidget {
  const PantallaHistorial({super.key});

  @override
  State<PantallaHistorial> createState() => _PantallaHistorialState();
}

class _PantallaHistorialState extends State<PantallaHistorial> {
  int _indiceNav = 1;
  List<String> tipos = ["Tipo incidente", "Estado", "Fecha"];
  int filtroActivo = 0;

  List<Reporte> reportes = [];
  bool cargando = true;
  String? error;

  final _reporteService = ReporteService(baseUrl: "http://192.168.1.220:5000");

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<int?> _obtenerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_usuario');
  }

  Future<void> _cargarReportes() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final usuarioId = await _obtenerUsuarioId();
      if (usuarioId == null) {
        setState(() {
          error = "No has iniciado sesión.";
          cargando = false;
        });
        return;
      }
      final lista = await _reporteService.obtenerReportes(usuarioId.toString());
      // Aquí depende cómo retorna tu service:
      // Si retorna List<Map<String, dynamic>>:
      setState(() {
        reportes = lista
            .map<Reporte>(
              (json) => Reporte.fromJson(json),
            )
            .toList();
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = "Error al cargar reportes: $e";
        cargando = false;
      });
    }
  }

  void _onNavTap(int i) {
    setState(() => _indiceNav = i);
    if (i == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/inicio', (_) => false);
    }
    if (i == 2) {
      Navigator.pushNamedAndRemoveUntil(context, '/ingreso', (_) => false);
    }
  }

  void _onEliminar(Reporte r) {
    setState(() {
      reportes.removeWhere((rep) => rep.id == r.id);
    });
  }

  void _onFavorito(Reporte r) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Funcionalidad no implementada")),
    );
  }

  void _onVerMapa(Reporte r) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Ver en mapa: ${r.direccion}")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Mis Reportes",
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: AppColors.azulPrincipal,
            ),
            label: const Text(
              "Filtrar por",
              style: TextStyle(color: AppColors.azulPrincipal),
            ),
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    itemCount: reportes.length,
                    itemBuilder: (context, i) {
                      final reporte = reportes[i];
                      return ReporteCard(
                        reporte: reporte,
                        onFavorito: () => _onFavorito(reporte),
                        onEliminar: () => _onEliminar(reporte),
                        onVerMapa: () => _onVerMapa(reporte),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detalle',
                            arguments: reporte,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BarraNav(indiceActual: _indiceNav, onTap: _onNavTap),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/zona_explorar_service.dart';
import '../utils/colors.dart';
import '../widgets/reporte_card.dart';
import '../models/reporte.dart';

class PantallaExplorarZonas extends StatefulWidget {
  const PantallaExplorarZonas({super.key});

  @override
  State<PantallaExplorarZonas> createState() => _PantallaExplorarZonasState();
}

class _PantallaExplorarZonasState extends State<PantallaExplorarZonas> {
  List<dynamic> distritos = [];
  List<dynamic> zonas = [];
  List<dynamic> reportes = [];
  int? distritoSeleccionado;
  int? zonaSeleccionada;
  Map<String, dynamic>? zonaStats;
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initPantalla();
  }

  Future<void> _initPantalla() async {
    setState(() => cargando = true);
    try {
      final service = ZonaExplorarService();
      final distritosData = await service.obtenerDistritos();
      final zonasData = await service.obtenerTodasZonas();
      final reportesData = await service.obtenerReportesZonas();
      setState(() {
        distritos = distritosData;
        zonas = zonasData;
        reportes = reportesData;
        distritoSeleccionado = null;
        zonaSeleccionada = null;
        zonaStats = null;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
        error = "Error al cargar datos: $e";
      });
    }
  }

  List<dynamic> get zonasFiltradas {
    final zs = distritoSeleccionado == null
        ? zonas
        : zonas.where((z) => z['id_distrito'] == distritoSeleccionado).toList();
    final nombresVistos = <String>{};
    final filtradas = <dynamic>[];
    for (var z in zs) {
      if (!nombresVistos.contains(z['nombre'])) {
        nombresVistos.add(z['nombre']);
        filtradas.add(z);
      }
    }
    return filtradas;
  }

  List<dynamic> get reportesFiltrados {
    List<dynamic> filtrados = reportes;
    if (zonaSeleccionada != null) {
      filtrados = filtrados.where((r) => r['id_zona'] == zonaSeleccionada).toList();
    } else if (distritoSeleccionado != null) {
      final zonasIds = zonasFiltradas.map((z) => z['id']).toSet();
      filtrados = filtrados.where((r) => zonasIds.contains(r['id_zona'])).toList();
    }
    return filtrados;
  }

  List<Polygon> get polygons {
    return zonasFiltradas.map<Polygon>((z) {
      final coords = (z['poligono'] as List)
          .map<LatLng>((c) => LatLng(c[1], c[0]))
          .toList();
      final color = colorPorDistrito(z['id_distrito']);
      return Polygon(
        points: coords,
        color: (zonaSeleccionada == null || z['id'] == zonaSeleccionada)
            ? color.withOpacity(0.24)
            : color.withOpacity(0.09),
        borderColor: color,
        borderStrokeWidth: (zonaSeleccionada == null || z['id'] == zonaSeleccionada) ? 3 : 1.3,
      );
    }).toList();
  }

  List<Marker> get markers {
    return reportesFiltrados
        .where((r) => r['latitud'] != null && r['longitud'] != null)
        .map<Marker>((r) => Marker(
              point: LatLng(r['latitud'], r['longitud']),
              width: 38,
              height: 38,
              child: Tooltip(
                message: r['descripcion'] ?? "",
                child: Icon(Icons.location_pin, color: Colors.red.shade600, size: 38),
              ),
            ))
        .toList();
  }

  LatLng get initialCenter {
    if (zonaSeleccionada != null) {
      final z = zonas.firstWhere((z) => z['id'] == zonaSeleccionada, orElse: () => null);
      if (z != null && z['poligono'] != null && z['poligono'].isNotEmpty) {
        return LatLng(z['poligono'][0][1], z['poligono'][0][0]);
      }
    }
    if (zonasFiltradas.isNotEmpty && zonasFiltradas[0]['poligono'].isNotEmpty) {
      return LatLng(zonasFiltradas[0]['poligono'][0][1], zonasFiltradas[0]['poligono'][0][0]);
    }
    return LatLng(-12.0464, -77.0428); // Lima centro
  }

  Future<void> _onSelectDistrito(int? nuevo) async {
    setState(() {
      distritoSeleccionado = nuevo;
      zonaSeleccionada = null;
      zonaStats = null;
    });
  }

  Future<void> _onSelectZona(int? nuevo) async {
    setState(() {
      zonaSeleccionada = nuevo;
      zonaStats = null;
      cargando = true;
    });
    if (nuevo != null) {
      final stats = await ZonaExplorarService().obtenerStatsZona(nuevo);
      setState(() {
        zonaStats = stats;
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Explorar Zonas",
            style: TextStyle(
                color: AppColors.textoOscuro,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                letterSpacing: -0.4)),
        leading: BackButton(color: AppColors.textoOscuro),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : Scrollbar(
                  thumbVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 26.0),
                      child: Column(
                        children: [
                          // --- FILTROS ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: "Distrito",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: AppColors.azulPrincipal, width: 1.3),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    ),
                                    value: distritoSeleccionado,
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: null,
                                        child: Text("Todos", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                      ...distritos.map<DropdownMenuItem<int>>((d) {
                                        return DropdownMenuItem<int>(
                                          value: d['id'],
                                          child: Text(d['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                        );
                                      }),
                                    ],
                                    onChanged: _onSelectDistrito,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    decoration: InputDecoration(
                                      labelText: "Zona",
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(color: AppColors.azulPrincipal, width: 1.3),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    ),
                                    value: zonaSeleccionada,
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem<int>(
                                        value: null,
                                        child: Text("Todas", style: TextStyle(fontWeight: FontWeight.w600)),
                                      ),
                                      ...zonasFiltradas.map<DropdownMenuItem<int>>((z) {
                                        return DropdownMenuItem<int>(
                                          value: z['id'],
                                          child: Text(z['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                        );
                                      }),
                                    ],
                                    onChanged: (nuevo) => _onSelectZona(nuevo),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // --- MAPA ---
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            elevation: 10,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: SizedBox(
                              height: 295,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: initialCenter,
                                      initialZoom: 14,
                                      minZoom: 11,
                                      maxZoom: 18,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.app',
                                      ),
                                      PolygonLayer(polygons: polygons),
                                      MarkerLayer(markers: markers),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // --- ESTADÍSTICAS ---
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              child: zonaSeleccionada != null && zonaStats != null
                                  ? _statsWidget(zonaStats!)
                                  : zonaSeleccionada == null
                                      ? _messageWidget("Selecciona una zona para ver estadísticas")
                                      : const SizedBox(height: 120),
                            ),
                          ),
                          // --- CARDS DE REPORTES ---
                          if (zonaSeleccionada != null && zonaStats != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: (zonaStats!['reportes'] as List).length,
                                itemBuilder: (context, i) {
                                  final json = zonaStats!['reportes'][i];
                                  final reporte = Reporte(
                                    id: (json['id'] ?? i).toString(),
                                    tipo: json['tipo'] ?? "",
                                    direccion: json['direccion'] ?? "",
                                    fecha: DateTime.tryParse((json['fecha'] ?? "").split(" ")[0]) ?? DateTime.now(),
                                    estado: json['estado'] ?? "",
                                    favorito: false,
                                  );
                                  return ReporteCard(
                                    reporte: reporte,
                                    onFavorito: () {},
                                    onEliminar: () {},
                                    onVerMapa: () {},
                                    onTap: null,
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // --- CARD DE ESTADÍSTICAS mejorada ---
  Widget _statsWidget(Map<String, dynamic> stats) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 5))],
        border: Border.all(color: AppColors.azulPrincipal.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _riskOrTypeCard(
                label: "Nivel de riesgo",
                valor: stats['nivel_riesgo'] ?? "-",
                color: _colorPorRiesgo(stats['nivel_riesgo']),
                tooltip: stats['tooltip_riesgo'] ?? "",
                icon: Icons.warning_amber_rounded,
              ),
              _riskOrTypeCard(
                label: "Tipo zona",
                valor: stats['tipo_zona'] ?? "-",
                color: _colorPorTipo(stats['tipo_zona']),
                tooltip: stats['tooltip_tipo'] ?? "",
                icon: Icons.place_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statGlassCard(
                icon: Icons.bolt_rounded,
                label: "Semana",
                valor: stats['incidentes_semana']?.toString() ?? "-",
                color: AppColors.azulPrincipal,
              ),
              _statGlassCard(
                icon: Icons.timeline_rounded,
                label: "Total históricos",
                valor: stats['total_incidentes']?.toString() ?? "-",
                color: Colors.indigo,
              ),
              _statGlassCard(
                icon: Icons.label_important_rounded,
                label: "Tipo + común",
                valor: stats['tipo_comun'] ?? "-",
                color: Colors.deepOrangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 11.0, bottom: 3, top: 3),
            child: Text("Reportes recientes:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _riskOrTypeCard({required String label, required String valor, required Color color, required String tooltip, required IconData icon}) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.38), width: 1.2),
            boxShadow: [BoxShadow(color: color.withOpacity(0.14), blurRadius: 7)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 3),
              Text(valor, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: color)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 13, color: color.withOpacity(0.85), fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statGlassCard({
    required IconData icon,
    required String label,
    required String valor,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 11),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: color.withOpacity(0.16), width: 1.2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.13), blurRadius: 10)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 7),
            Text(
              valor,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21, color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.4, color: color.withOpacity(0.95), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageWidget(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: TextStyle(fontSize: 16, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color colorPorDistrito(int idDistrito) {
    final List<Color> colores = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
      Colors.amber,
    ];
    return colores[idDistrito % colores.length];
  }

  Color _colorPorRiesgo(String? riesgo) {
    switch (riesgo) {
      case "Alto":
        return Colors.redAccent;
      case "Medio":
        return Colors.amber.shade800;
      case "Bajo":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _colorPorTipo(String? tipo) {
    switch (tipo) {
      case "Roja":
        return Colors.red;
      case "Amarilla":
        return Colors.amber;
      case "Verde":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

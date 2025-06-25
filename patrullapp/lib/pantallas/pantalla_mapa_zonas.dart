/*import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/zona_explorar_service.dart'; // crea este service
import '../utils/colors.dart';

class PantallaExplorarZonas extends StatefulWidget {
  const PantallaExplorarZonas({super.key});

  @override
  State<PantallaExplorarZonas> createState() => _PantallaExplorarZonasState();
}

class _PantallaExplorarZonasState extends State<PantallaExplorarZonas> {
  List<dynamic> distritos = [];
  List<dynamic> zonas = [];
  Map<String, dynamic>? zonaInfo;

  int? distritoSeleccionado;
  int? zonaSeleccionada;
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarDistritos();
  }

  Future<void> _cargarDistritos() async {
    setState(() => cargando = true);
    try {
      final data = await ZonaExplorarService().obtenerDistritos();
      setState(() {
        distritos = data;
        if (distritos.isNotEmpty) {
          distritoSeleccionado = distritos[0]['id'];
          _cargarZonas(distritoSeleccionado!);
        }
      });
    } catch (e) {
      setState(() {
        cargando = false;
        error = "Error al cargar distritos: $e";
      });
    }
  }

  Future<void> _cargarZonas(int distritoId) async {
    setState(() => cargando = true);
    try {
      final data = await ZonaExplorarService().obtenerZonas(distritoId);
      setState(() {
        zonas = data;
        zonaSeleccionada = zonas.isNotEmpty ? zonas[0]['id'] : null;
        cargando = false;
      });
      if (zonaSeleccionada != null) {
        _cargarInfoZona(zonaSeleccionada!);
      }
    } catch (e) {
      setState(() {
        cargando = false;
        error = "Error al cargar zonas: $e";
      });
    }
  }

  Future<void> _cargarInfoZona(int zonaId) async {
    setState(() => cargando = true);
    try {
      final data = await ZonaExplorarService().obtenerInfoZona(zonaId);
      setState(() {
        zonaInfo = data;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        cargando = false;
        error = "Error al cargar info de zona: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Explorar Zonas",
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        leading: BackButton(color: AppColors.textoOscuro),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown Distrito
                  DropdownButton<int>(
                    value: distritoSeleccionado,
                    isExpanded: true,
                    items: distritos.map<DropdownMenuItem<int>>((d) {
                      return DropdownMenuItem<int>(
                        value: d['id'],
                        child: Text(d['nombre']),
                      );
                    }).toList(),
                    onChanged: (nuevo) {
                      setState(() {
                        distritoSeleccionado = nuevo;
                        zonaSeleccionada = null;
                        zonas = [];
                        zonaInfo = null;
                      });
                      _cargarZonas(nuevo!);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Dropdown Zona
                  DropdownButton<int>(
                    value: zonaSeleccionada,
                    isExpanded: true,
                    items: zonas.map<DropdownMenuItem<int>>((z) {
                      return DropdownMenuItem<int>(
                        value: z['id'],
                        child: Text(z['nombre']),
                      );
                    }).toList(),
                    onChanged: (nuevo) {
                      setState(() {
                        zonaSeleccionada = nuevo;
                        zonaInfo = null;
                      });
                      _cargarInfoZona(nuevo!);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (zonaInfo != null)
                    Expanded(
                      child: ListView(
                        children: [
                          // Mapa
                          if (zonaInfo!['poligono'] != null)
                            SizedBox(
                              height: 200,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    zonaInfo!['poligono'][0][1], // lat
                                    zonaInfo!['poligono'][0][0], // lng
                                  ),
                                  initialZoom: 15,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  PolygonLayer(
                                    polygons: [
                                      Polygon(
                                        points: zonaInfo!['poligono']
                                            .map<LatLng>(
                                              (c) => LatLng(c[1], c[0]),
                                            )
                                            .toList(),
                                        color: AppColors.azulPrincipal
                                            .withOpacity(0.3),
                                        borderStrokeWidth: 2,
                                        borderColor: AppColors.azulPrincipal,
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(
                                    markers: (zonaInfo!['marcadores'] ?? [])
                                        .map<Marker>((m) {
                                          return Marker(
                                            point: LatLng(m[1], m[0]),
                                            width: 38,
                                            height: 38,
                                            child: const Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 38,
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 14),
                          // Estadísticas principales
                          Row(
                            children: [
                              _statCard(
                                "Incidentes esta semana",
                                zonaInfo!['incidentes_semana'].toString(),
                              ),
                              _statCard(
                                "Último incidente",
                                zonaInfo!['ultimo_incidente'] ?? "-",
                              ),
                              _statCard(
                                "Tipo + común",
                                zonaInfo!['tipo_comun'] ?? "-",
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Listado de reportes
                          Text(
                            "Reportes recientes:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...((zonaInfo!['reportes'] ?? []) as List)
                              .map<Widget>(
                                (r) => ListTile(
                                  title: Text(r['descripcion'] ?? ""),
                                  subtitle: Text(r['direccion'] ?? ""),
                                  trailing: Text(r['estado'] ?? ""),
                                ),
                              ),
                          const SizedBox(height: 10),
                          // Botón para guardar como favorito
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.star_border),
                            label: const Text("Guardar zona como favorita"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.azulPrincipal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String valor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}*/

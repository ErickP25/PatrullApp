import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/navbar.dart';
import '../utils/colors.dart';
import '../services/zona_service.dart';
import '../utils/ubicacion_utils.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final int _indiceNav = 0;
  final ZonaService _zonaService = ZonaService(
    baseUrl: "http://192.168.100.46:5000",
  ); // Cambia por tu backend real
  Map<String, dynamic>? _zonaData;
  Map<String, dynamic>? _incidentesData;
  LatLng? _posicionUsuario;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarZonaYIncidentes();
  }

  Future<void> _cargarZonaYIncidentes() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final posicion = await UbicacionUtils.obtenerUbicacionActual();
      if (posicion == null) {
        setState(() {
          _error = "Permiso de ubicación denegado.";
          _cargando = false;
        });
        return;
      }
      final lat = posicion.latitude;
      final lon = posicion.longitude;
      final zona = await _zonaService.obtenerZonaPorUbicacion(lat, lon);
      final incidentes = await _zonaService.obtenerIncidentesPorUbicacion(
        lat,
        lon,
      );

      setState(() {
        _posicionUsuario = LatLng(lat, lon);
        _zonaData = zona;
        _incidentesData = incidentes;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error al cargar zona: $e";
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tu Zona',
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _cargarZonaYIncidentes,
            icon: const Icon(
              Icons.map_outlined,
              color: AppColors.azulPrincipal,
            ),
            label: const Text(
              "Explorar zonas",
              style: TextStyle(color: AppColors.azulPrincipal),
            ),
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _buildContenido(),
      bottomNavigationBar: BarraNav(
        indiceActual: 0,
        onTap: (nuevoIndice) {
          if (nuevoIndice == 0) {
            /* ya aquí */
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

  Widget _buildContenido() {
    if (_zonaData == null || _incidentesData == null) {
      return const Center(
        child: Text('No se encontró zona para tu ubicación.'),
      );
    }
    final zona = _zonaData!;
    final nombreZona = zona['properties']['nombre_zona'];
    final cantIncidentes = zona['properties']['cant_incidentes'] ?? 0;
    final List puntos = _incidentesData!['features'] ?? [];

    // Decodifica el polígono de la zona (GeoJSON)
    final poligono = zona['geometry']['coordinates'][0]
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mapa interactivo
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: SizedBox(
            height: 240,
            child: FlutterMap(
              options: MapOptions(
                initialCenter:
                    _posicionUsuario ??
                    LatLng(-12.05, -77.05), // centro de Lima por defecto
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: List<LatLng>.from(poligono),
                      color: AppColors.azulPrincipal.withOpacity(0.2),
                      borderStrokeWidth: 2,
                      borderColor: AppColors.azulPrincipal,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: puntos
                      .map<Marker>(
                        (p) => Marker(
                          point: LatLng(
                            p['geometry']['coordinates'][1],
                            p['geometry']['coordinates'][0],
                          ),
                          width: 34,
                          height: 34,
                          child: const Icon(
                            Icons.place,
                            color: Colors.red,
                            size: 34,
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (_posicionUsuario != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _posicionUsuario!,
                        width: 36,
                        height: 36,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        // Información de la zona e incidentes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$nombreZona presenta $cantIncidentes incidentes reportados en la última semana.",
                style: const TextStyle(
                  color: AppColors.textoOscuro,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.place),
                      label: const Text("Reportar Incidente"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulPrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/reporte');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.warning_amber_rounded),
                      label: const Text("Alerta de Emergencia"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rojoAlerta,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/alerta');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(),
              // Lista resumida de los incidentes recientes
              if (puntos.isNotEmpty)
                ...puntos
                    .take(4)
                    .map<Widget>(
                      (p) => ListTile(
                        leading: const Icon(
                          Icons.report,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          p['properties']['descripcion'] ?? "Incidente",
                        ),
                        subtitle: Text(
                          "ID: ${p['properties']['id_reporte']}",
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
              if (puntos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("No hay incidentes recientes en tu zona."),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

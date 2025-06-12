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
    baseUrl: "http://192.168.1.219:5000",
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
            Navigator.pushNamedAndRemoveUntil(context, '/reporte', (_) => false);
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
              initialCenter: _posicionUsuario ?? LatLng(-12.05, -77.05),
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
      // Resumen visual bonito de la zona
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: AppColors.azulPrincipal, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreZona.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.azulPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$cantIncidentes incidentes reportados en la última semana.",
                      style: const TextStyle(
                        color: AppColors.textoOscuro,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // Espacio antes de los botones
      const SizedBox(height: 24),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.place),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    "Reportar Incidente",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.azulPrincipal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
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
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    "Alerta de Emergencia",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rojoAlerta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/alerta');
                },
              ),
            ),
          ],
        ),
      ),
      // Nada más abajo, todo bien centrado y bonito!
      const SizedBox(height: 16),
    ],
  );
}
}

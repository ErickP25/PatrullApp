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
  final ZonaService _zonaService = ZonaService(
    baseUrl: "http://172.17.148.195:5000",
  );
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
            onPressed: () {
              Navigator.pushNamed(context, '/mapa_zonas');
            },
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
          : RefreshIndicator(
              onRefresh: _cargarZonaYIncidentes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: _buildContenido(),
              ),
            ),
      bottomNavigationBar: BarraNav(
        indiceActual: 0,
        onTap: (nuevoIndice) {
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
    final nombreDistrito = zona['properties']['nombre_distrito'] ?? "";

    // Decodifica el polígono de la zona (GeoJSON)
    final poligono = zona['geometry']['coordinates'][0]
        .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
        .toList();

    // ==== Marcadores de incidentes ====
    final List<Marker> incidentMarkers = (_incidentesData!['features'] as List)
        .map<Marker>(
          (feature) => Marker(
            point: LatLng(
              feature['geometry']['coordinates'][1],
              feature['geometry']['coordinates'][0],
            ),
            width: 36,
            height: 36,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
          ),
        )
        .toList();

    // Marcador de la ubicación del usuario
    if (_posicionUsuario != null) {
      incidentMarkers.add(
        Marker(
          point: _posicionUsuario!,
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.azulPrincipal, width: 3),
            ),
            child: const Icon(Icons.my_location, color: Colors.blue, size: 32),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==== TARJETA DEL DISTRITO (arriba del mapa) ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.location_city,
                    color: AppColors.azulPrincipal,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nombreDistrito.isNotEmpty
                          ? "Distrito: $nombreDistrito"
                          : "Distrito no encontrado",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textoOscuro,
                        fontSize: 18,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ==== MAPA INTERACTIVO ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: SizedBox(
              height: 270,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _posicionUsuario ?? LatLng(-12.05, -77.05),
                  initialZoom: 15,
                  minZoom: 11,
                  maxZoom: 19,
                  interactionOptions: const InteractionOptions(
                    flags:
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.drag |
                        InteractiveFlag.doubleTapZoom,
                  ),
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
                        points: List<LatLng>.from(poligono),
                        color: AppColors.azulPrincipal.withOpacity(0.2),
                        borderStrokeWidth: 2,
                        borderColor: AppColors.azulPrincipal,
                      ),
                    ],
                  ),
                  MarkerLayer(markers: incidentMarkers),
                ],
              ),
            ),
          ),
          // ==== TARJETA DE LA ZONA ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
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
              padding: const EdgeInsets.symmetric(vertical: 19, horizontal: 18),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: AppColors.azulPrincipal,
                    size: 38,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreZona.toUpperCase(),
                          style: TextStyle(
                            color: AppColors.azulPrincipal,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$cantIncidentes incidentes reportados en la última semana.",
                          style: const TextStyle(
                            color: AppColors.textoOscuro,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // ==== BOTONES GRANDES MEJORADOS ====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/reporte');
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.azulPrincipal,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.azulPrincipal.withOpacity(
                                  0.22,
                                ),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          width: 78,
                          height: 78,
                          child: const Icon(
                            Icons.place,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Reportar\nIncidente",
                          style: TextStyle(
                            color: AppColors.azulPrincipal,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 36),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/alerta');
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.rojoAlerta,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rojoAlerta.withOpacity(0.22),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          width: 78,
                          height: 78,
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Alerta de\nEmergencia",
                          style: TextStyle(
                            color: AppColors.rojoAlerta,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

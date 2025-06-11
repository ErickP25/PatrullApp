import 'dart:convert';
import 'package:http/http.dart' as http;

class ZonaService {
  final String baseUrl;

  ZonaService({required this.baseUrl});

  // Consulta zona por ubicación
  Future<Map<String, dynamic>?> obtenerZonaPorUbicacion(
    double lat,
    double lon,
  ) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/ver_cantidad_incidentes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitud': lat, 'longitud': lon}),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    return null;
  }

  // Consulta incidentes (pines) por ubicación
  Future<Map<String, dynamic>?> obtenerIncidentesPorUbicacion(
    double lat,
    double lon,
  ) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/ver_incidentes_en_zona'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'latitud': lat, 'longitud': lon}),
    );
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body);
    }
    return null;
  }
}

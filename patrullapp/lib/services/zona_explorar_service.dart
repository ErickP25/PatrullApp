import 'dart:convert';
import 'package:http/http.dart' as http;

class ZonaExplorarService {
  final String baseUrl = "http://192.168.1.219:5000"; // Cambia por tu IP si es necesario

  /// Obtiene la lista de distritos (para filtros)
  Future<List<dynamic>> obtenerDistritos() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/distritos'));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      }
      return [];
    } catch (e) {
      print("Error en obtenerDistritos: $e");
      return [];
    }
  }

  /// Obtiene todas las zonas (incluye polígono, id_distrito, etc)
  Future<List<dynamic>> obtenerTodasZonas() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/zonas_todas'));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      }
      return [];
    } catch (e) {
      print("Error en obtenerTodasZonas: $e");
      return [];
    }
  }

  /// Obtiene todos los reportes/incidentes de todas las zonas
  Future<List<dynamic>> obtenerReportesZonas() async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/reportes_zonas'));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      }
      return [];
    } catch (e) {
      print("Error en obtenerReportesZonas: $e");
      return [];
    }
  }

  /// Obtiene las estadísticas y reportes recientes para una zona
  Future<Map<String, dynamic>> obtenerStatsZona(int zonaId) async {
    try {
      final resp = await http.get(Uri.parse('$baseUrl/api/zona_stats?zona_id=$zonaId'));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body);
      }
      return {};
    } catch (e) {
      print("Error en obtenerStatsZona: $e");
      return {};
    }
  }
}

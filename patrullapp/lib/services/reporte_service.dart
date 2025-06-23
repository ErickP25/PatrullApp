import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reporte.dart';

class ReporteService {
  final String baseUrl;
  ReporteService({required this.baseUrl});

  // Enviar reporte existente
  /*Future<bool> enviarReporte(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/guardar_reporte'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    return response.statusCode == 200;
  }*/

  // Nuevo: Obtener reportes por id_vecino y convertirlos a objetos Reporte
  Future<List<Map<String, dynamic>>> obtenerReportes(String idVecino) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/mis_reportes?id_vecino=$idVecino'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Ahora accede a la lista
      final List<dynamic> lista = data['reportes'] ?? [];
      return lista.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener reportes');
    }
  }
}

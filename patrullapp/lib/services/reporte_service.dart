import 'dart:convert';
import 'package:http/http.dart' as http;

class ReporteService {
  final String baseUrl;
  ReporteService({required this.baseUrl});

  Future<bool> enviarReporte(Map<String, dynamic> datos) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/guardar_reporte'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    return response.statusCode == 200;
  }
}

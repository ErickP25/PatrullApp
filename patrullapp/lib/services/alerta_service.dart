import 'dart:convert';
import 'package:http/http.dart' as http;

class AlertaService {
  final String baseUrl;
  AlertaService({required this.baseUrl});

  Future<Map<String, dynamic>> enviarAlerta({
    required String direccion,
    required double latitud,
    required double longitud,
  }) async {
    final uri = Uri.parse('$baseUrl/api/emergencia');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Error enviando alerta: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

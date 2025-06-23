import 'dart:convert';
import 'package:http/http.dart' as http;

class RegistroService {
  final String baseUrl;
  RegistroService({required this.baseUrl});

  Future<Map<String, dynamic>> registrarVecino(
    Map<String, dynamic> datos,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/registro'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datos),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error en el registro',
      );
    }
  }
}

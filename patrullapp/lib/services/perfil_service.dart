// lib/services/perfil_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PerfilService {
  final String baseUrl;
  PerfilService({required this.baseUrl});

  Future<Map<String, dynamic>> obtenerPerfil(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/perfil?id_usuario=$idUsuario'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener perfil');
    }
  }
}

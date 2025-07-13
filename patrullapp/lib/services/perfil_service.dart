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

  Future<void> actualizarPerfil(Map<String, dynamic> datos) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/perfil'),
      body: jsonEncode(datos),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) throw Exception('Error al actualizar perfil');
  }

  Future<void> actualizarFotoPerfil(int idUsuario, String fotoUrl) async {
    final resp = await http.put(
      Uri.parse('$baseUrl/api/perfil/foto'),
      body: jsonEncode({'id_usuario': idUsuario, 'foto_url': fotoUrl}),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) throw Exception('Error al actualizar foto');
  }

  Future<void> cambiarPassword(int idUsuario, String oldPwd, String newPwd) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/cambiar_password'),
      body: jsonEncode({
        'id_usuario': idUsuario, // asegurate que es int, no string
        'old_password': oldPwd,
        'new_password': newPwd,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode != 200) {
      throw Exception(jsonDecode(resp.body)['error'] ?? 'Error al cambiar contraseña');
    }
  }

}

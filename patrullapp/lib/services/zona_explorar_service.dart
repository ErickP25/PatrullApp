/*import 'dart:convert';
import 'package:http/http.dart' as http;

class ZonaExplorarService {
  final String baseUrl = "http://192.168.100.46:5000"; // ajusta si cambia

  Future<List<dynamic>> obtenerDistritos() async {
    final res = await http.get(Uri.parse('$baseUrl/api/distritos'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error distritos");
  }

  Future<List<dynamic>> obtenerZonas(int distritoId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/zonas?distrito_id=$distritoId'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error zonas");
  }

  Future<Map<String, dynamic>> obtenerInfoZona(int zonaId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/zona_info?zona_id=$zonaId'),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception("Error info zona");
  }
}*/

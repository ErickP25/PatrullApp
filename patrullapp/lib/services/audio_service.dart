import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';



class AudioService {
  final String baseUrl;
  AudioService({required this.baseUrl});

  // Envía audio y obtiene la transcripción (y datos de GPT si aplica)
  Future<Map<String, dynamic>?> enviarAudio(File audio, String usuarioId) async {
    var uri = Uri.parse('$baseUrl/api/reportar_incidente');
    var request = http.MultipartRequest('POST', uri)
      ..fields['usuario_id'] = usuarioId
      ..files.add(
        await http.MultipartFile.fromPath(
          'audio', audio.path,
          contentType: MediaType('audio', 'wav'), // Cambia según extensión
        ),
      );
    var res = await request.send();
    if (res.statusCode == 200) {
      final respStr = await res.stream.bytesToString();
      return jsonDecode(respStr);
    }
    return null;
  }
}

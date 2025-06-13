import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AudioService {
  final String baseUrl;

  AudioService({required this.baseUrl});

  Future<Map<String, dynamic>?> enviarAudio({
    required File audioFile,
    required String usuarioId,
    required String direccion,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$baseUrl/api/crear_incidente');

    final request = http.MultipartRequest('POST', uri)
      ..fields['usuario_id'] = usuarioId
      ..fields['direccion'] = direccion
      ..fields['latitud'] = latitude.toString()
      ..fields['longitud'] = longitude.toString()
      ..files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      throw Exception(
        'Error enviando audio: ${response.statusCode} - $responseBody',
      );
    }
  }
}

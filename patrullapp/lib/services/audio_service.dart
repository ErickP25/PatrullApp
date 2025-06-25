import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class AudioService {
  final String baseUrl;
  AudioService({required this.baseUrl});

  // Solo transcribe, NO guarda reporte
  Future<Map<String, dynamic>?> transcribirAudio({
    required File audioFile,
    required String direccion,
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transcribir_audio');

    final request = http.MultipartRequest('POST', uri)
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
        'Error transcribiendo audio: ${response.statusCode} - $responseBody',
      );
    }
  }
}

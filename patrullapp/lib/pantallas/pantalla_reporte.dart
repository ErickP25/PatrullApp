import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../services/audio_service.dart';
import '../services/firebase_storage_service.dart';
import '../utils/colors.dart';
import '../utils/ubicacion_utils.dart';
import '../widgets/navbar.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

enum EstadoGrabacion { inicio, grabando, revisando }

class PantallaReporte extends StatefulWidget {
  const PantallaReporte({super.key});

  @override
  State<PantallaReporte> createState() => _PantallaReporteState();
}

class _PantallaReporteState extends State<PantallaReporte> {
  EstadoGrabacion estado = EstadoGrabacion.inicio;
  bool cargando = false;
  String? error;
  String transcripcion = "";
  String tipoIncidente = "";
  String referencia = "";
  File? audioFile;
  File? evidenciaFile;
  String? evidenciaUrl;
  String direccion = "";
  Position? posicion;

  late AudioRecorder _audioRecorder;
  String? _audioPath;

  final _audioService = AudioService(baseUrl: "http://192.168.1.219:5000"); // Cambia por tu backend
  final _storageService = FirebaseStorageService();

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _obtenerUbicacion();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      setState(() => cargando = true);
      final pos = await UbicacionUtils.obtenerUbicacionActual();
      if (pos != null) {
        final placemarks = await geo.placemarkFromCoordinates(pos.latitude, pos.longitude);
        final place = placemarks.first;
        setState(() {
          posicion = pos;
          direccion = [
            place.street,
            place.thoroughfare,
            place.subLocality,
            place.locality
          ].where((e) => e != null && e.isNotEmpty).join(", ");
        });
      } else {
        setState(() => error = "No se pudo obtener ubicación");
      }
    } catch (e) {
      setState(() => error = "Error obteniendo ubicación: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  // Iniciar grabación de audio
  Future<void> _grabarAudio() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      setState(() => error = "Permiso de micrófono denegado");
      return;
    }

    setState(() {
      estado = EstadoGrabacion.grabando;
      error = null;
    });

    final tempPath = Directory.systemTemp.path;
    final fileName = 'incidente_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: '$tempPath/$fileName',
    );
  }

  // Detener grabación y enviar/transcribir
  Future<void> _detenerGrabacion() async {
    setState(() => cargando = true);

    final path = await _audioRecorder.stop();
    if (path == null) {
      setState(() {
        error = "No se grabó audio";
        cargando = false;
      });
      return;
    }
    setState(() {
      audioFile = File(path);
      _audioPath = path;
      estado = EstadoGrabacion.revisando;
    });

    try {
      const usuarioId = "1";
      final resp = await _audioService.enviarAudio(audioFile!, usuarioId);
      setState(() {
        transcripcion = resp?['transcripcion'] ?? "";
        tipoIncidente = resp?['tipo'] ?? "";
        referencia = resp?['referencia'] ?? "";
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = "Error al transcribir audio: $e";
        cargando = false;
      });
    }
  }

  // Subir evidencia (foto)
  Future<void> _subirEvidencia() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => cargando = true);
    try {
      final url = await _storageService.subirArchivo(
        File(file.path),
        'evidencias',
      );
      setState(() {
        evidenciaFile = File(file.path);
        evidenciaUrl = url;
      });
    } catch (e) {
      setState(() => error = "Error subiendo evidencia: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  // Enviar reporte
  Future<void> _enviarReporte() async {
    setState(() => cargando = true);
    // Aquí deberías llamar a tu servicio de reportes (POST /api/reportar_incidente con todos los campos)
    // Por ahora solo simula
    await Future.delayed(const Duration(seconds: 2));
    setState(() => cargando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Reporte enviado!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.grisFondo,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textoOscuro),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Nuevo Incidente', style: TextStyle(color: AppColors.textoOscuro)),
            elevation: 0,
          ),
          body: cargando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ubicación
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16, top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place, color: AppColors.azulPrincipal),
                            const SizedBox(width: 7),
                            Expanded(child: Text(direccion.isNotEmpty ? direccion : "Obteniendo ubicación...", style: const TextStyle(fontWeight: FontWeight.w500))),
                          ],
                        ),
                      ),
                      // AUDIO Y TRANSCRIPCIÓN
                      if (estado == EstadoGrabacion.inicio)
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.mic, size: 38, color: Colors.white),
                                label: const Text("Grabar audio", style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rojoAlerta,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: _grabarAudio,
                              ),
                              const SizedBox(height: 10),
                              const Text("Describe lo sucedido claramente, indicando dirección", style: TextStyle(fontStyle: FontStyle.italic)),
                            ],
                          ),
                        ),
                      if (estado == EstadoGrabacion.grabando)
                        Center(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.stop, size: 38, color: Colors.white),
                                label: const Text("Detener grabación", style: TextStyle(fontSize: 16)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rojoAlerta,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: _detenerGrabacion,
                              ),
                              const SizedBox(height: 10),
                              const Text("Grabando...", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.rojoAlerta)),
                            ],
                          ),
                        ),
                      if (estado == EstadoGrabacion.revisando)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.play_circle_fill, color: AppColors.azulPrincipal, size: 36),
                              title: Text(transcripcion, style: const TextStyle(fontStyle: FontStyle.italic)),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _mostrarDialogoEdicion("Descripción", transcripcion, (nuevo) => setState(() => transcripcion = nuevo));
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text("Tipo de incidente:", style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(tipoIncidente, style: const TextStyle(fontWeight: FontWeight.w400)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _mostrarDialogoEdicion("Tipo de incidente", tipoIncidente, (nuevo) => setState(() => tipoIncidente = nuevo)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("Referencia:", style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(referencia, style: const TextStyle(fontWeight: FontWeight.w400)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18),
                                  onPressed: () => _mostrarDialogoEdicion("Referencia", referencia, (nuevo) => setState(() => referencia = nuevo)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 18),
                      // EVIDENCIA
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(evidenciaFile == null ? "Subir evidencia" : "Evidencia seleccionada"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textoOscuro,
                          minimumSize: const Size(double.infinity, 48),
                          side: const BorderSide(color: AppColors.azulPrincipal, width: 1.2),
                        ),
                        onPressed: _subirEvidencia,
                      ),
                      if (evidenciaFile != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.file(evidenciaFile!, height: 90),
                        ),
                      // ERRORES
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),
                      // BOTONES FINALES
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.azulPrincipal,
                                minimumSize: const Size(0, 48),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              onPressed: (estado == EstadoGrabacion.revisando && transcripcion.isNotEmpty)
                                  ? _enviarReporte
                                  : null,
                              child: const Text("Enviar Reporte"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.grisBoton,
                                foregroundColor: Colors.grey,
                                minimumSize: const Size(0, 48),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancelar"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: const BarraNav(indiceActual: 0),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoEdicion(String titulo, String valorActual, ValueChanged<String> onConfirm) async {
    final controlador = TextEditingController(text: valorActual);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $titulo'),
        content: TextField(controller: controlador, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
              onPressed: () {
                onConfirm(controlador.text);
                Navigator.pop(context);
              },
              child: const Text("Guardar"))
        ],
      ),
    );
  }
}

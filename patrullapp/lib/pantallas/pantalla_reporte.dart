import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../services/audio_service.dart';
import '../services/firebase_storage_service.dart';
import '../services/reporte_service.dart';
import '../utils/colors.dart';
import '../utils/ubicacion_utils.dart';
import '../widgets/navbar.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final _audioService = AudioService(baseUrl: "http://192.168.1.219:5000");
  final _storageService = FirebaseStorageService();
  final _reporteService = ReporteService(baseUrl: "http://192.168.1.219:5000");

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
        final placemarks = await geo.placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );
        final place = placemarks.first;
        setState(() {
          posicion = pos;
          direccion = [
            place.street,
            place.thoroughfare,
            place.subLocality,
            place.locality,
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
    final fileName = 'incidente_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 44100),
      path: '$tempPath/$fileName',
    );
  }

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
      final resp = await _audioService.transcribirAudio(
        audioFile: audioFile!,
        direccion: direccion,
        latitude: posicion?.latitude ?? 0.0,
        longitude: posicion?.longitude ?? 0.0,
      );

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

  Future<void> _enviarReporte() async {
    setState(() => cargando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('id_usuario');

      if (usuarioId == null) {
        setState(() {
          cargando = false;
          error = "Usuario no autenticado. Inicia sesión de nuevo.";
        });
        return;
      }

      final exito = await _reporteService.enviarReporte({
        'id_vecino': usuarioId,
        'descripcion': transcripcion,
        'direccion': direccion,
        'latitud': posicion?.latitude,
        'longitud': posicion?.longitude,
        'tipo_incidente': tipoIncidente,
      });

      setState(() => cargando = false);

      if (!exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar el reporte.")),
        );
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("¡Reporte enviado!")));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        error = "Error al enviar reporte: $e";
        cargando = false;
      });
    }
  }

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
            title: const Text(
              'Nuevo Incidente',
              style: TextStyle(color: AppColors.textoOscuro),
            ),
            elevation: 0,
          ),
          body: cargando
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- UBICACIÓN ----
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 18, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place,
                              color: AppColors.azulPrincipal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                direccion.isNotEmpty
                                    ? direccion
                                    : "Obteniendo ubicación...",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ---- AUDIO & TRANSCRIPCIÓN ----
                      if (estado == EstadoGrabacion.inicio)
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _grabarAudio,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: AppColors.rojoAlerta,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.rojoAlerta.withOpacity(
                                          0.13,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Describe el incidente por voz",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textoOscuro,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      if (estado == EstadoGrabacion.grabando)
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.rojoAlerta,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rojoAlerta.withOpacity(
                                        0.13,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.stop,
                                    color: Colors.white,
                                    size: 54,
                                  ),
                                  onPressed: _detenerGrabacion,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Grabando...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.rojoAlerta,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (estado == EstadoGrabacion.revisando)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24, top: 2),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 7,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transcripción editable
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                      right: 12,
                                      top: 5,
                                    ),
                                    child: const Icon(
                                      Icons.graphic_eq,
                                      color: AppColors.azulPrincipal,
                                      size: 36,
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _mostrarDialogoEdicion(
                                          "Descripción",
                                          transcripcion,
                                          (nuevo) => setState(
                                            () => transcripcion = nuevo,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 2,
                                        ),
                                        child: Text(
                                          transcripcion,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.textoOscuro,
                                            height: 1.38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 22,
                                      color: AppColors.azulPrincipal,
                                    ),
                                    onPressed: () {
                                      _mostrarDialogoEdicion(
                                        "Descripción",
                                        transcripcion,
                                        (nuevo) => setState(
                                          () => transcripcion = nuevo,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              // Tipo de incidente
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tipo de incidente:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      tipoIncidente,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _mostrarDialogoEdicion(
                                      "Tipo de incidente",
                                      tipoIncidente,
                                      (nuevo) =>
                                          setState(() => tipoIncidente = nuevo),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Referencia:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      referencia,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => _mostrarDialogoEdicion(
                                      "Referencia",
                                      referencia,
                                      (nuevo) =>
                                          setState(() => referencia = nuevo),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      // ==== SUBIR EVIDENCIA ====
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file_rounded),
                          label: Text(
                            evidenciaFile == null
                                ? "Subir evidencia"
                                : "Evidencia seleccionada",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textoOscuro,
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(
                              color: AppColors.azulPrincipal,
                              width: 1.2,
                            ),
                          ),
                          onPressed: _subirEvidencia,
                        ),
                      ),
                      if (evidenciaFile != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.file(evidenciaFile!, height: 90),
                        ),
                      // ==== ERRORES ====
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      // ==== BOTONES FINALES ====
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.azulPrincipal,
                                  minimumSize: const Size(0, 54),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed:
                                    (estado == EstadoGrabacion.revisando &&
                                        transcripcion.isNotEmpty)
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
                                  minimumSize: const Size(0, 54),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
          bottomNavigationBar: const BarraNav(indiceActual: 0),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoEdicion(
    String titulo,
    String valorActual,
    ValueChanged<String> onConfirm,
  ) async {
    final controlador = TextEditingController(text: valorActual);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar $titulo'),
        content: TextField(controller: controlador, maxLines: 3),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm(controlador.text);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}

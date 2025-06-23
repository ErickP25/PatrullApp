import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../services/alerta_service.dart';
import '../utils/colors.dart';
import '../utils/ubicacion_utils.dart';
import '../widgets/navbar.dart';

class PantallaAlerta extends StatefulWidget {
  const PantallaAlerta({super.key});

  @override
  State<PantallaAlerta> createState() => _PantallaAlertaState();
}

class _PantallaAlertaState extends State<PantallaAlerta> {
  final _alertaService = AlertaService(
    baseUrl: "http://192.168.100.46:5000",
  ); // cambia IP
  String direccion = "";
  Position? posicion;
  bool cargando = false;
  String? mensaje;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacion();
  }

  Future<void> _obtenerUbicacion() async {
    setState(() => cargando = true);
    try {
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
        setState(() => mensaje = "No se pudo obtener ubicación");
      }
    } catch (e) {
      setState(() => mensaje = "Error obteniendo ubicación: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  Future<void> _enviarAlerta() async {
    setState(() {
      cargando = true;
      mensaje = null;
    });
    try {
      if (posicion == null || direccion.isEmpty) {
        setState(() => mensaje = "No hay ubicación válida.");
        return;
      }
      final resp = await _alertaService.enviarAlerta(
        direccion: direccion,
        latitud: posicion!.latitude,
        longitud: posicion!.longitude,
      );
      setState(
        () => mensaje = "¡Alerta enviada con éxito! Patrullero en camino.",
      );
    } catch (e) {
      setState(() => mensaje = "Error al enviar alerta: $e");
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoOscuro),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Alerta de Emergencia',
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        elevation: 0,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 26, top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: AppColors.azulPrincipal),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            direccion.isNotEmpty
                                ? direccion
                                : "Obteniendo ubicación...",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: (posicion != null && !cargando)
                        ? _enviarAlerta
                        : null,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.rojoAlerta,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.rojoAlerta.withOpacity(0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "¡Presiona el botón si necesitas ayuda urgente!\nUn patrullero irá a tu ubicación.",
                    style: TextStyle(
                      color: AppColors.textoOscuro,
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  if (mensaje != null)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: mensaje!.contains('éxito')
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mensaje!,
                        style: TextStyle(
                          color: mensaje!.contains('éxito')
                              ? Colors.green[900]
                              : Colors.red[900],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const BarraNav(indiceActual: 0),
    );
  }
}

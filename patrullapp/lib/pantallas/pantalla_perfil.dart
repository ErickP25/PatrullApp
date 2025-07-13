import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/navbar.dart';
import '../widgets/badge_reputacion.dart';
import '../widgets/perfil_info_row.dart';
import '../utils/colors.dart';
import '../services/perfil_service.dart';
import '../services/firebase_storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  Map<String, dynamic>? perfil;
  bool cargando = true;
  String? error;
  bool recibirNotificaciones = true;

  final _perfilService = PerfilService(baseUrl: "http://192.168.1.219:5000");
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _cargarPerfil();
  }

  Future<void> _cargarPerfil() async {
    setState(() {
      cargando = true;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('id_usuario');
      if (idUsuario == null) {
        setState(() {
          error = "No has iniciado sesión.";
          cargando = false;
        });
        return;
      }
      final data = await _perfilService.obtenerPerfil(idUsuario);
      setState(() {
        perfil = data;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = "Error al cargar perfil: $e";
        cargando = false;
      });
    }
  }

  void _mostrarAyudaReputacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Qué es la reputación?"),
        content: const Text(
          "Es un indicador del nivel de confiabilidad del usuario. Se basa en el número de reportes confirmados frente a falsas alarmas. Una buena reputación mejora la prioridad de atención.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  void _cerrarSesion() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Estás seguro que deseas cerrar sesión?"),
        content: const Text(
          "Perderás el acceso a la aplicación hasta iniciar sesión nuevamente.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.azulPrincipal,
            ),
            child: const Text("Cerrar sesión"),
          ),
        ],
      ),
    );
    if (confirmado ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, '/ingreso', (_) => false);
    }
  }

  void _cambiarContrasena() {
    Navigator.pushNamed(context, '/cambiar_password');
  }

  void _editarPerfil() async {
    if (perfil == null) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditarPerfilDialog(
        nombre: perfil!['nombre'] ?? '',
        apellido: perfil!['apellido'] ?? '',
        telefono: perfil!['telefono'] ?? '',
        direccion: perfil!['direccion'] ?? '',
      ),
    );
    if (result != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final idUsuario = prefs.getInt('id_usuario');
        await _perfilService.actualizarPerfil({
          'id_usuario': idUsuario,
          ...result,
        });
        await _cargarPerfil();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _subirNuevaFoto() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
      if (picked == null) return;

      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('id_usuario');
      final url = await FirebaseStorageService().subirArchivo(File(picked.path), "fotos_perfil");
      if (url != null) {
        await _perfilService.actualizarFotoPerfil(idUsuario!, url);
        await _cargarPerfil();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto de perfil actualizada")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No se pudo subir la foto")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mi perfil",
          style: TextStyle(color: AppColors.textoOscuro, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.azulPrincipal),
            tooltip: 'Editar perfil',
            onPressed: _editarPerfil,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: AppColors.azulPrincipal.withOpacity(0.14),
                            backgroundImage: (perfil?['foto_url'] != null && perfil!['foto_url'] != "")
                                ? NetworkImage(perfil!['foto_url'])
                                : const AssetImage('assets/user_placeholder.png') as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 12,
                            child: GestureDetector(
                              onTap: _subirNuevaFoto,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: AppColors.azulPrincipal, width: 1.2),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [BoxShadow(color: AppColors.azulPrincipal.withOpacity(0.09), blurRadius: 6)],
                                ),
                                padding: const EdgeInsets.all(7),
                                child: const Icon(Icons.camera_alt_rounded, color: AppColors.azulPrincipal, size: 26),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "${perfil?['nombre'] ?? ''} ${perfil?['apellido'] ?? ''}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "DNI : ${perfil?['dni'] ?? ''}",
                            style: const TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          BadgeReputacion(
                            reputacion: perfil?['reputacion'] ?? "Sin reputación",
                            onTap: _mostrarAyudaReputacion,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 23),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 7)],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Estadísticas",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.azulPrincipal,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _infoStat("Reportes realizados", perfil?['reportes']),
                          _infoStat("Alertas de emergencia", perfil?['alertas']),
                          _infoStat("Incidentes confirmados", perfil?['confirmados']),
                        ],
                      ),
                    ),
                    const SizedBox(height: 17),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 7)],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Column(
                        children: [
                          PerfilInfoRow(
                            icono: Icons.phone,
                            texto: "Teléfono: ${perfil?['telefono'] ?? '-'}",
                          ),
                          PerfilInfoRow(
                            icono: Icons.home_outlined,
                            texto: "Dirección: ${perfil?['direccion'] ?? '-'}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Recibir notificaciones"),
                      value: recibirNotificaciones,
                      onChanged: (val) => setState(() => recibirNotificaciones = val),
                      activeColor: AppColors.azulPrincipal,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
                      child: Column(
                        children: [
                          PerfilInfoRow(
                            icono: Icons.lock_outline,
                            texto: "Cambiar contraseña",
                            onTap: _cambiarContrasena,
                          ),
                          PerfilInfoRow(
                            icono: Icons.logout,
                            texto: "Cerrar sesión",
                            onTap: _cerrarSesion,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BarraNav(
        indiceActual: 2,
        onTap: (nuevoIndice) {
          if (nuevoIndice == 0) {
            Navigator.pushNamedAndRemoveUntil(context, '/inicio', (_) => false);
          }
          if (nuevoIndice == 1) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/historial',
              (_) => false,
            );
          }
        },
      ),
    );
  }

  Widget _infoStat(String label, int? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7, left: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const Spacer(),
          Text(
            valor?.toString() ?? "-",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.azulPrincipal),
          ),
        ],
      ),
    );
  }
}

// --- MODAL DE EDICIÓN DE PERFIL ---
class _EditarPerfilDialog extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String telefono;
  final String direccion;
  const _EditarPerfilDialog({
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.direccion,
  });

  @override
  State<_EditarPerfilDialog> createState() => _EditarPerfilDialogState();
}

class _EditarPerfilDialogState extends State<_EditarPerfilDialog> {
  late TextEditingController _nombreCtrl, _apellidoCtrl, _telefonoCtrl, _direccionCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombre);
    _apellidoCtrl = TextEditingController(text: widget.apellido);
    _telefonoCtrl = TextEditingController(text: widget.telefono);
    _direccionCtrl = TextEditingController(text: widget.direccion);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Editar Perfil"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: _apellidoCtrl,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),
            TextField(
              controller: _telefonoCtrl,
              decoration: const InputDecoration(labelText: "Teléfono"),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _direccionCtrl,
              decoration: const InputDecoration(labelText: "Dirección"),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'nombre': _nombreCtrl.text,
              'apellido': _apellidoCtrl.text,
              'telefono': _telefonoCtrl.text,
              'direccion': _direccionCtrl.text,
            });
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulPrincipal),
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}

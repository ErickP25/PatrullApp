import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/navbar.dart';
import '../widgets/badge_reputacion.dart';
import '../widgets/perfil_info_row.dart';
import '../utils/colors.dart';
import '../services/perfil_service.dart';

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

  final _perfilService = PerfilService(baseUrl: "http://172.17.148.195:5000");

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

  void _cambiarContrasena() async {
    // Implementa tu lógica aquí o navega a un formulario de cambio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Redirigiendo a cambio de contraseña (demo)"),
      ),
    );
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
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        centerTitle: false,
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 43,
                        backgroundImage: const NetworkImage(
                          "https://randomuser.me/api/portraits/men/32.jpg",
                        ),
                        backgroundColor: AppColors.azulPrincipal.withOpacity(
                          0.15,
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        "${perfil?['nombre'] ?? ''} ${perfil?['apellido'] ?? ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "DNI : ${perfil?['dni'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 11),
                      BadgeReputacion(
                        reputacion: perfil?['reputacion'] ?? "Sin reputación",
                        onTap: _mostrarAyudaReputacion,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Estadísticas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(height: 11),
                _infoStat("Reportes realizados", perfil?['reportes']),
                _infoStat("Alertas de emergencia", perfil?['alertas']),
                _infoStat("Incidentes confirmados", perfil?['confirmados']),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Recibir notificaciones"),
                  value: recibirNotificaciones,
                  onChanged: (val) =>
                      setState(() => recibirNotificaciones = val),
                  activeColor: AppColors.azulPrincipal,
                ),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            valor?.toString() ?? "-",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

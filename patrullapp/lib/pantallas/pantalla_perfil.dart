import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/badge_reputacion.dart';
import '../widgets/perfil_info_row.dart';
import '../models/usuario.dart';
import '../utils/colors.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  // Usuario de ejemplo, cámbialo por tu lógica de backend/autenticación
  final Usuario usuario = Usuario(
    nombre: "Oscar Gonzales",
    correo: "oscargonzales@gmail.com",
    dni: "7182934",
    reputacion: "Buena reputación",
    reportes: 7,
    alertas: 2,
    confirmados: 5,
  );

  bool recibirNotificaciones = true;

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
      // Si quieres puedes limpiar datos de sesión aquí
      Navigator.pushNamedAndRemoveUntil(context, '/ingreso', (_) => false);
    }
  }

  void _cambiarContrasena() async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Deseas cambiar tu contraseña?"),
        content: const Text("Serás redirigido al formulario de cambio."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
    if (confirmado ?? false) {
      // Aquí lógica para ir a cambio de contraseña
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Redirigiendo a cambio de contraseña (demo)"),
        ),
      );
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
          style: TextStyle(color: AppColors.textoOscuro),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        children: [
          // Foto de perfil y datos básicos
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundImage: const NetworkImage(
                    "https://randomuser.me/api/portraits/men/32.jpg",
                  ),
                  backgroundColor: AppColors.azulPrincipal.withOpacity(0.15),
                ),
                const SizedBox(height: 11),
                Text(
                  usuario.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  usuario.correo,
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  "DNI : ${usuario.dni}",
                  style: const TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 11),
                BadgeReputacion(
                  reputacion: usuario.reputacion,
                  onTap: _mostrarAyudaReputacion,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Estadísticas
          Text(
            "Estadísticas",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.azulPrincipal,
            ),
          ),
          const SizedBox(height: 11),
          _infoStat("Reportes realizados", usuario.reportes),
          _infoStat("Alertas de emergencia", usuario.alertas),
          _infoStat("Incidentes confirmados", usuario.confirmados),
          const SizedBox(height: 16),
          // Opciones
          SwitchListTile(
            title: const Text("Recibir notificaciones"),
            value: recibirNotificaciones,
            onChanged: (val) => setState(() => recibirNotificaciones = val),
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
          if (nuevoIndice == 2) {
            /* ya estás aquí */
          }
        },
      ),
    );
  }

  Widget _infoStat(String label, int valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            valor.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

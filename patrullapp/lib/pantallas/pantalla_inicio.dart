import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../utils/colors.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  final int _indiceNav = 0;

  String distritoSeleccionado = 'Comas';
  String zonaSeleccionada = 'Zona Cms-02';

  // TODO: Reemplaza por un widget real de mapa (Google Maps)
  Widget _mapaSimulado() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.grisFondo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Mapa con zonas y pines (Aquí va Google Maps)', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grisFondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Tu Zona', style: TextStyle(color: AppColors.textoOscuro)),
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.map_outlined, color: AppColors.azulPrincipal),
            label: const Text("Explorar zonas", style: TextStyle(color: AppColors.azulPrincipal)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de distrito y zona
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _SelectorSimple(
                  label: "Distrito",
                  valor: distritoSeleccionado,
                  onTap: () {}, // lógica para seleccionar distrito
                ),
                const SizedBox(width: 16),
                _SelectorSimple(
                  label: "Zona",
                  valor: zonaSeleccionada,
                  onTap: () {}, // lógica para seleccionar zona
                ),
              ],
            ),
          ),
          // Mapa
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _mapaSimulado(),
          ),
          // Indicador de incidentes
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              "Zona Cms-02 presenta 12 incidentes reportados en la última semana.",
              style: TextStyle(color: AppColors.textoOscuro),
            ),
          ),
          // Botones grandes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _BotonGrande(
                  icono: Icons.place,
                  color: AppColors.azulPrincipal,
                  texto: "Reportar\nIncidente",
                  onTap: () {
                    Navigator.pushNamed(context, '/reporte');
                  },
                ),
                const SizedBox(width: 24),
                _BotonGrande(
                  icono: Icons.warning_amber_rounded,
                  color: AppColors.rojoAlerta,
                  texto: "Alerta de\nEmergencia",
                  onTap: () {
                    Navigator.pushNamed(context, '/alerta');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BarraNav(
  indiceActual: 0, // 0: Principal
  onTap: (nuevoIndice) {
    if (nuevoIndice == 0) {/* ya estás aquí */}
    if (nuevoIndice == 1) Navigator.pushNamedAndRemoveUntil(context, '/historial', (_) => false);
    if (nuevoIndice == 2) Navigator.pushNamedAndRemoveUntil(context, '/perfil', (_) => false);
  },
),
    );
  }
}

// --- Widgets auxiliares para la UI principal ---

class _BotonGrande extends StatelessWidget {
  final IconData icono;
  final Color color;
  final String texto;
  final VoidCallback onTap;
  const _BotonGrande({
    required this.icono,
    required this.color,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, color: color, size: 48),
              const SizedBox(height: 10),
              Text(
                texto,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorSimple extends StatelessWidget {
  final String label;
  final String valor;
  final VoidCallback onTap;
  const _SelectorSimple({
    required this.label,
    required this.valor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.azulPrincipal),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

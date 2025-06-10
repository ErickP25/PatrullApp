class Reporte {
  final String id;
  final String tipo;
  final String direccion;
  final DateTime fecha;
  final String estado; // "En espera", "Atendido", "Falsa alarma"
  final bool favorito;

  Reporte({
    required this.id,
    required this.tipo,
    required this.direccion,
    required this.fecha,
    required this.estado,
    this.favorito = false,
  });
}

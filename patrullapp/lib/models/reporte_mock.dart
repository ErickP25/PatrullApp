// modelo para probar como se ve la pantalla_historial (provisional hasta conectar con el backend)
class Reporte {
  final String id;
  final String tipo;
  final String direccion;
  final DateTime fecha;
  final String estado;
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

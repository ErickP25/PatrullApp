class Usuario {
  final String nombre;
  final String correo;
  final String dni;
  final String reputacion; // 'Buena reputación', 'Mala reputación', etc.
  final int reportes;
  final int alertas;
  final int confirmados;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.dni,
    required this.reputacion,
    required this.reportes,
    required this.alertas,
    required this.confirmados,
  });
}

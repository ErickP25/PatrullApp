class Reporte {
  final String id;
  final String tipo; // Puede venir como 'tipo' o 'tipo_incidente'
  final String direccion;
  final DateTime fecha;
  final String estado;
  final bool favorito;

  // Opcionales
  final String? descripcion;
  final String? prioridad;
  final String? atendidoPor;
  final String? tiempoRespuesta;

  Reporte({
    required this.id,
    required this.tipo,
    required this.direccion,
    required this.fecha,
    required this.estado,
    this.favorito = false,
    this.descripcion,
    this.prioridad,
    this.atendidoPor,
    this.tiempoRespuesta,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    // Soporte flexible para el campo id y tipo
    final fechaString = json['fecha'] ?? '';
    DateTime fechaParsed;
    try {
      fechaParsed = DateTime.parse(fechaString);
    } catch (_) {
      fechaParsed = DateTime.now(); // Si hay error, usa ahora
    }

    return Reporte(
      id: json['id']?.toString() ?? json['id_reporte']?.toString() ?? '',
      tipo: json['tipo'] ?? json['tipo_incidente'] ?? 'Sin tipo',
      direccion: json['direccion'] ?? '',
      fecha: fechaParsed,
      estado: json['estado']?.toString() ?? "En espera",
      favorito: json['favorito'] ?? false,
      descripcion: json['descripcion'],
      prioridad: json['prioridad'],
      atendidoPor: json['atendido_por'],
      tiempoRespuesta: json['tiempo_respuesta'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_reporte': id,
    'tipo': tipo,
    'direccion': direccion,
    'fecha': fecha.toIso8601String(),
    'estado': estado,
    'favorito': favorito,
    'descripcion': descripcion,
    'prioridad': prioridad,
    'atendido_por': atendidoPor,
    'tiempo_respuesta': tiempoRespuesta,
  };
}

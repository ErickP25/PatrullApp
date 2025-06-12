class Reporte {
  final String descripcion;
  final String direccion;
  final double latitud;
  final double longitud;
  final String? urlEvidencia;
  final String tipoIncidente;
  final String usuarioId;

  Reporte({
    required this.descripcion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.urlEvidencia,
    required this.tipoIncidente,
    required this.usuarioId,
  });

  Map<String, dynamic> toJson() => {
        'descripcion': descripcion,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'url_evidencia': urlEvidencia,
        'tipo_incidente': tipoIncidente,
        'usuario_id': usuarioId,
      };
}

class Usuario {
  final int id;
  final String nombre;
  final String apellido;
  final String dni;
  final String telefono;
  final String direccion;
  final bool esSereno; // tipo_usuario: false = vecino, true = sereno
  final int? idReputacion;
  final String? reputacionTexto;

  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.telefono,
    required this.direccion,
    required this.esSereno,
    this.idReputacion,
    this.reputacionTexto,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_usuario'],
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      dni: json['dni'] ?? '',
      telefono: json['telefono'] ?? '',
      direccion: json['direccion'] ?? '',
      esSereno: json['tipo_usuario'] ?? false,
      idReputacion: json['id_reputacion'],
      reputacionTexto: json['reputacion'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_usuario': id,
    'nombre': nombre,
    'apellido': apellido,
    'dni': dni,
    'telefono': telefono,
    'direccion': direccion,
    'tipo_usuario': esSereno,
    'id_reputacion': idReputacion,
    'reputacion': reputacionTexto,
  };
}

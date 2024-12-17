class Notificacion {
  /// Fecha de la notificación.
  final DateTime fecha;

  /// ID de la clase.
  final String idClase;

  /// Nombre del profesor.
  final String profesor;

  /// Materiales de la notificación. Es un mapa de ID del material a la cantidad.
  final Map<String, int> materiales;

  /// Indica si la notificación ha sido vista.
  bool vista;

  /// Constructor de la clase [Notificacion].
  Notificacion({
    required this.fecha,
    required this.idClase,
    required this.profesor,
    required this.materiales,
    this.vista = false,
  });

  /// Método para convertir una instancia de [Notificacion] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'idClase': idClase,
      'profesor': profesor,
      'materiales': materiales,
      'vista': vista,
    };
  }

  /// Método para crear una instancia de [Notificacion] a partir de un mapa.
  factory Notificacion.fromMap(Map<String, dynamic> map) {
    return Notificacion(
      fecha: DateTime.parse(map['fecha']),
      idClase: map['idClase'],
      profesor: map['profesor'],
      materiales: Map<String, int>.from(map['materiales'] ?? {}),
      vista: map['vista']
    );
  }
}
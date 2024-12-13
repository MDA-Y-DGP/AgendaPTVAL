class Notificacion {
  final DateTime fecha;
  final String idClase;
  final String profesor;
  final Map<String, int> materiales;  // Cambié a Map<String, int>
  bool vista;

  Notificacion({
    required this.fecha,
    required this.idClase,
    required this.profesor,
    required this.materiales,
    this.vista = false,
  });

  // Método para convertir a un mapa para almacenamiento o uso posterior
  Map<String, dynamic> toMap() {
    return {
      'fecha': fecha.toIso8601String(),
      'idClase': idClase,
      'profesor': profesor,
      'materiales': materiales,  // Este Map ya está bien formado
      'vista': vista,
    };
  }

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

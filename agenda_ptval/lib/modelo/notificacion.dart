class Notificacion {
  final DateTime fecha;
  final String idClase;
  final String profesor;
  final List<Map<String, dynamic>> materiales;
  bool vista; // Para saber si la notificación ha sido vista

  Notificacion({
    required this.fecha,
    required this.idClase,
    required this.profesor,
    required this.materiales,
    this.vista = false, // Inicialmente no vista
  });
}

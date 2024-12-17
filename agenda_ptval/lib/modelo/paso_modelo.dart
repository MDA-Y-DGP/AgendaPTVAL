/// Modelo que representa un paso de una tarea.
class Paso {
  /// ID del paso.
  final int idPaso;

  /// ID de la tarea por pasos a la que pertenece este paso.
  final int idTareaPorPasos;

  /// Texto del paso.
  final String texto;

  /// URL de los medios asociados al paso. Puede ser nulo si no se sube ningún archivo.
  final String? urlMedia;

  /// Constructor de la clase [Paso].
  Paso({
    required this.idPaso,
    required this.idTareaPorPasos,
    required this.texto,
    this.urlMedia,
  });

  /// Método para convertir una instancia de [Paso] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'idPaso': idPaso,
      'idTareaPorPasos': idTareaPorPasos,
      'texto': texto,
      'urlMedia': urlMedia,
    };
  }
}
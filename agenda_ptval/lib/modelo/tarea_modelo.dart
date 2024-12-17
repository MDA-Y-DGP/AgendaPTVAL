class Tarea {
  /// ID de la tarea.
  final int idTarea;

  /// Título de la tarea.
  final String titulo;

  /// Descripción de la tarea.
  final String descripcion;

  /// Tipo de la tarea.
  final String tipo;

  /// Materiales necesarios para la tarea. Es un mapa de ID del material a la cantidad.
  final Map<String, int> materiales;

  /// Pasos de la tarea. Es una lista opcional de pasos.
  final List<String>? pasos;

  /// Evaluación de la tarea. Es opcional.
  String? evaluacion;

  /// Fecha de la tarea. Es opcional.
  String? fecha;

  /// ID de Firebase de la tarea. Es opcional.
  String? idFirebase;

  /// Indica si la tarea está completada. Es opcional.
  bool? completado;

  /// Constructor de la clase [Tarea].
  Tarea({
    required this.idTarea,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.materiales = const {}, // Valor predeterminado de mapa vacío
    this.pasos,
    this.evaluacion,
    this.fecha,
    this.idFirebase,
    this.completado,
  });

  /// Método para convertir una instancia de [Tarea] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'idTarea': idTarea,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'materiales': materiales, // Agregar los materiales al map
      'pasos': pasos,
      'evaluacion': evaluacion,
      'fecha': fecha,
      'idFirebase': idFirebase,
      'completado': completado,
    };
  }

  /// Método para crear una instancia de [Tarea] a partir de un mapa.
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      idTarea: map['idTarea'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      materiales: Map<String, int>.from(map['materiales']),
      pasos: List<String>.from(map['pasos'] ?? []),
      evaluacion: map['evaluacion'],
      fecha: map['fecha'],
      idFirebase: map['idFirebase'],
      completado: map['completado'],
    );
  }
}
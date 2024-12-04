class Tarea {
  final int idTarea;
  final String titulo;
  final String descripcion;
  final String tipo;
  final List<String>? pasos; // Array de pasos
  String? evaluacion;
  String? fecha;
  String? idFirebase;
  bool? completado;

  Tarea({
    required this.idTarea,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.pasos,
    this.evaluacion,
    this.fecha,
    this.idFirebase,
    this.completado,
  });

  Map<String, dynamic> toMap() {
    return {
      'idTarea': idTarea,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'pasos': pasos,
      'evaluacion': evaluacion,
      'fecha': fecha,
      'idFirebase': idFirebase,
      'completado': completado,
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      idTarea: map['idTarea'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      pasos: List<String>.from(map['pasos'] ?? []),
      evaluacion: map['evaluacion'],
      fecha: map['fecha'],
      idFirebase: map['idFirebase'],
      completado: map['completado'] ?? false,
    );
  }
}
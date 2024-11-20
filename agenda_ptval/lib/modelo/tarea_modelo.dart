class Tarea {
  final int idTarea;
  final String titulo;
  final String descripcion;
  final String tipo;
  final List<String>? pasos; // Array de pasos

  Tarea({
    required this.idTarea,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.pasos,
  });

  Map<String, dynamic> toMap() {
    return {
      'idTarea': idTarea,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'pasos': pasos,
    };
  }

  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      idTarea: map['idTarea'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      pasos: List<String>.from(map['pasos'] ?? []),
    );
  }
}
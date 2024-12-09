class Tarea {
  final int idTarea;
  final String titulo;
  final String descripcion;
  final String tipo;
  final List<String>? pasos; // Array de pasos
  final List<List<String?>>? mediaUrls; // Array of media URLs for each step
  final List<List<String?>>? imageUrls; // Array of image URLs for each step
  final List<List<String?>>? videoUrls; // Array of video URLs for each step
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
    this.mediaUrls,
    this.imageUrls,
    this.videoUrls,
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
      'mediaUrls': mediaUrls,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
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
      mediaUrls: (map['mediaUrls'] as List<dynamic>?)
          ?.map((e) => List<String?>.from(e))
          .toList(),
      imageUrls: (map['imageUrls'] as List<dynamic>?)
          ?.map((e) => List<String?>.from(e))
          .toList(),
      videoUrls: (map['videoUrls'] as List<dynamic>?)
          ?.map((e) => List<String?>.from(e))
          .toList(),
      evaluacion: map['evaluacion'],
      fecha: map['fecha'],
      idFirebase: map['idFirebase'],
      completado: map['completado'] ?? false,
    );
  }
}
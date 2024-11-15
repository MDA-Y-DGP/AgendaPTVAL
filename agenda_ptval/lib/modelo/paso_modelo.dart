class Paso {
  final int idPaso;
  final int idTareaPorPasos;
  final String texto;
  final String? urlMedia; // Puede ser nulo si no se sube ningún archivo

  Paso({
    required this.idPaso,
    required this.idTareaPorPasos,
    required this.texto,
    this.urlMedia,
  });

  Map<String, dynamic> toMap() {
    return {
      'idPaso': idPaso,
      'idTareaPorPasos': idTareaPorPasos,
      'texto': texto,
      'urlMedia': urlMedia,
    };
  }
}
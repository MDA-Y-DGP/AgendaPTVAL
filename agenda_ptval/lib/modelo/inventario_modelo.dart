class Inventario {
  /// ID del objeto.
  final int idObjeto;

  /// Nombre del objeto.
  final String nombre;

  /// Cantidad del objeto.
  int cantidad;

  /// Constructor de la clase [Inventario].
  Inventario({
    required this.idObjeto,
    required this.nombre,
    required this.cantidad,
  });

  /// Método para convertir una instancia de [Inventario] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'id_objeto': idObjeto,
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }

  /// Método para crear una instancia de [Inventario] a partir de un mapa.
  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
      idObjeto: map['id_objeto'],
      nombre: map['nombre'],
      cantidad: map['cantidad'],
    );
  }
}
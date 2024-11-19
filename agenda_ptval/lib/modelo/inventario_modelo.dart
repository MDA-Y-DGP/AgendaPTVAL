class Inventario {
  final int idObjeto;
  final String nombre;
  final int cantidad;

  Inventario({
    required this.idObjeto,
    required this.nombre,
    required this.cantidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_objeto': idObjeto,
      'nombre': nombre,
      'cantidad': cantidad,
    };
  }

  factory Inventario.fromMap(Map<String, dynamic> map) {
    return Inventario(
      idObjeto: map['id_objeto'],
      nombre: map['nombre'],
      cantidad: map['cantidad'],
    );
  }
}
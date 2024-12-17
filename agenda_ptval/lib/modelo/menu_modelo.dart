class Menu {
  /// ID del menú.
  final int idMenu;

  /// Nombre del menú.
  final String nombre;

  /// Descripción del menú.
  final String descripcion;

  /// Constructor de la clase [Menu].
  Menu({
    required this.idMenu,
    required this.nombre,
    required this.descripcion,
  });

  /// Método para convertir una instancia de [Menu] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'id_menu': idMenu,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  /// Método para crear una instancia de [Menu] a partir de un mapa.
  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      idMenu: map['id_menu'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
    );
  }
}
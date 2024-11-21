import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/clase_modelo.dart';

/// Controlador para manejar las operaciones relacionadas con las clases.
class ClaseController {
  /// Instancia de Firestore para acceder a la base de datos.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Método privado para obtener todas las clases y encontrar el mayor ID.
  /// 
  /// Devuelve el mayor ID encontrado entre las clases.
  Future<int> _obtenerMayorIdClase() async {
    QuerySnapshot snapshot = await _firestore.collection('clases').get();
    int maxId = 0;

    for (var doc in snapshot.docs) {
      int currentId = doc['id_clase'] as int;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }

    return maxId;
  }

  /// Método para agregar una nueva clase.
  /// 
  /// [clase] es la instancia de [Clase] que se va a agregar.
  /// Asigna un nuevo ID a la clase y la guarda en la base de datos.
  Future<void> agregarClase(Clase clase) async {
    try {
      // Obtener el mayor ID de las clases existentes
      int maxId = await _obtenerMayorIdClase();

      // Asignar a la nueva clase un ID que sea uno más que el mayor ID encontrado
      int newId = maxId + 1;

      // Crear un nuevo documento en la colección "clases" con el nuevo ID
      await _firestore.collection('clases').add({
        'id_clase': newId,
        'nombre': clase.nombre,
      });
    } catch (e) {
      throw Exception('Error al agregar clase: $e');
    }
  }

  /// Método para obtener todas las clases.
  /// 
  /// Devuelve una lista de instancias de [Clase].
  Future<List<Clase>> obtenerClases() async {
    QuerySnapshot snapshot = await _firestore.collection('clases').get();
    return snapshot.docs.map((doc) => Clase.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  /// Método para actualizar el nombre de una clase.
/// 
/// [idClase] es el identificador único de la clase a actualizar.
/// [nuevoNombre] es el nuevo nombre que se asignará.
Future<void> actualizarClase(int idClase, String nuevoNombre) async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('clases')
        .where('id_clase', isEqualTo: idClase)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({'nombre': nuevoNombre});
    }
  } catch (e) {
    throw Exception('Error al actualizar la clase: $e');
  }
}

/// Método para borrar una clase.
/// 
/// [idClase] es el identificador único de la clase que se quiere eliminar.
Future<void> borrarClase(int idClase) async {
  try {
    QuerySnapshot snapshot = await _firestore
        .collection('clases')
        .where('id_clase', isEqualTo: idClase)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  } catch (e) {
    throw Exception('Error al borrar la clase: $e');
  }
}

}
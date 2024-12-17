import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/inventario_modelo.dart';

/// Controlador para manejar las operaciones relacionadas con el inventario.
class InventarioController {
  /// Colección de inventario en Firestore.
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  /// Método para obtener todo el inventario.
  /// 
  /// Devuelve una lista de instancias de [Inventario].
  Future<List<Inventario>> obtenerInventario() async {
    QuerySnapshot querySnapshot = await _inventarioCollection.get();
    return querySnapshot.docs.map((doc) {
      return Inventario.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Método para obtener la imagen de un objeto por su nombre.
  /// 
  /// [nombre] es el nombre del objeto.
  /// Devuelve la ruta de la imagen del objeto.
  String obtenerImagenPorNombre(String nombre) {
    return 'materiales/$nombre.jpg';
  }

  /// Método para eliminar un objeto del inventario.
  /// 
  /// [idObjeto] es el ID del objeto que se quiere eliminar.
  Future<void> eliminarInventario(int idObjeto) async {
    QuerySnapshot querySnapshot = await _inventarioCollection
        .where('id_objeto', isEqualTo: idObjeto)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.delete();
    } else {
      throw Exception('No se encontró el objeto con este ID');
    }
  }

  /// Método para agregar un nuevo objeto al inventario.
  /// 
  /// [inventario] es la instancia de [Inventario] que se va a agregar.
  Future<void> agregarInventario(Inventario inventario) async {
    await _inventarioCollection.add(inventario.toMap());
  }

  /// Método para actualizar un objeto del inventario.
  /// 
  /// [inventario] es la instancia de [Inventario] que se va a actualizar.
  Future<void> actualizarInventario(Inventario inventario) async {
    QuerySnapshot querySnapshot = await _inventarioCollection
        .where('id_objeto', isEqualTo: inventario.idObjeto)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update(inventario.toMap());
    } else {
      throw Exception('No se encontró el objeto con este ID');
    }
  }
}
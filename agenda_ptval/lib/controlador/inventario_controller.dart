import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/inventario_modelo.dart';

class InventarioController {
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  Future<void> agregarInventario(Inventario inventario) async {
    // Verificar si ya existe un objeto con el mismo id_objeto
    QuerySnapshot existingInventarioSnapshot = await _inventarioCollection
        .where('id_objeto', isEqualTo: inventario.idObjeto)
        .get();

    if (existingInventarioSnapshot.docs.isNotEmpty) {
      throw Exception('Ya existe un objeto con este ID');
    }

    // Guardar el nuevo inventario en Firestore
    await _inventarioCollection.add(inventario.toMap());
  }

  Future<List<Inventario>> obtenerInventario() async {
    QuerySnapshot querySnapshot = await _inventarioCollection.get();
    return querySnapshot.docs.map((doc) {
      return Inventario.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> actualizarInventario(Inventario inventario) async {
    // Obtener el documento con el id_objeto correspondiente
    QuerySnapshot querySnapshot = await _inventarioCollection
        .where('id_objeto', isEqualTo: inventario.idObjeto)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Actualizar el documento
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update(inventario.toMap());
    } else {
      throw Exception('No se encontró el objeto con este ID');
    }
  }

  Future<void> actualizarInventarioPorNombre(String nombre, int nuevaCantidad) async {
    // Obtener el documento con el nombre correspondiente
    QuerySnapshot querySnapshot = await _inventarioCollection
        .where('nombre', isEqualTo: nombre)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Actualizar la cantidad del documento
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update({'cantidad': nuevaCantidad});
    } else {
      throw Exception('No se encontró el objeto con este nombre');
    }
  }

  Future<void> eliminarInventario(int idObjeto) async {
    // Obtener el documento con el id_objeto correspondiente
    QuerySnapshot querySnapshot = await _inventarioCollection
        .where('id_objeto', isEqualTo: idObjeto)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Eliminar el documento
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.delete();
    } else {
      throw Exception('No se encontró el objeto con este ID');
    }
  }
}
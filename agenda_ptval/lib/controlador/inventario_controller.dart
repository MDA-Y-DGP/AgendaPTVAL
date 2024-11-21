import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/inventario_modelo.dart';

class InventarioController {
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  Future<List<Inventario>> obtenerInventario() async {
    QuerySnapshot querySnapshot = await _inventarioCollection.get();
    return querySnapshot.docs.map((doc) {
      return Inventario.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  String obtenerImagenPorNombre(String nombre) {
    return 'materiales/$nombre.jpg';
  }

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

  Future<void> agregarInventario(Inventario inventario) async {
    await _inventarioCollection.add(inventario.toMap());
  }

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

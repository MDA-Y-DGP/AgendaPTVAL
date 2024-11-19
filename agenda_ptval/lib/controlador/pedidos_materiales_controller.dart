import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/pedido_materiales_modelo.dart';
import 'package:agenda_ptval/modelo/inventario_modelo.dart';

class PedidosMaterialesController {
  final CollectionReference _pedidosCollection =
      FirebaseFirestore.instance.collection('pedidos');
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  Future<void> agregarPedido(PedidoMateriales pedido) async {
    QuerySnapshot existingPedidoSnapshot = await _pedidosCollection
        .where('id_clase', isEqualTo: pedido.idClase)
        .where('fecha', isEqualTo: Timestamp.fromDate(DateTime(pedido.fecha.year, pedido.fecha.month, pedido.fecha.day)))
        .get();

    if (existingPedidoSnapshot.docs.isNotEmpty) {
      DocumentSnapshot existingPedidoDoc = existingPedidoSnapshot.docs.first;
      List<Inventario> existingMateriales = List<Inventario>.from(
        existingPedidoDoc['materiales'].map((x) => Inventario.fromMap(x)),
      );

      for (var material in pedido.materiales) {
        int index = existingMateriales.indexWhere((m) => m.idObjeto == material.idObjeto);
        if (index != -1) {
          existingMateriales[index].cantidad += material.cantidad;
        } else {
          existingMateriales.add(material);
        }
      }

      await existingPedidoDoc.reference.update({
        'materiales': existingMateriales.map((material) => material.toMap()).toList(),
      });
    } else {
      await _pedidosCollection.add(pedido.toMap());
    }

    // Actualizar la cantidad disponible en el inventario
    for (var material in pedido.materiales) {
      DocumentSnapshot inventarioDoc = await _inventarioCollection
          .where('id_objeto', isEqualTo: material.idObjeto)
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first);

      if (inventarioDoc.exists) {
        int nuevaCantidad = (inventarioDoc['cantidad'] as int) - material.cantidad;
        await inventarioDoc.reference.update({'cantidad': nuevaCantidad});
      }
    }
  }
}
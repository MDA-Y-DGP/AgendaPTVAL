import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/paso_modelo.dart';

class PasoController {
  final CollectionReference _pasosCollection =
      FirebaseFirestore.instance.collection('pasos');

  Future<void> crearPaso(Paso paso) async {
    // Obtener todos los pasos para encontrar el mayor ID
    QuerySnapshot querySnapshot = await _pasosCollection.get();
    int maxId = 0;

    for (var doc in querySnapshot.docs) {
      int currentId = doc['idPaso'] as int;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }

    // Asignar al nuevo paso un ID que sea uno más que el mayor ID encontrado
    int newId = maxId + 1;

    // Crear el nuevo paso con el ID asignado
    Paso nuevoPaso = Paso(
      idPaso: newId,
      idTareaPorPasos: paso.idTareaPorPasos,
      texto: paso.texto,
      urlMedia: paso.urlMedia,
    );

    // Guardar el nuevo paso en Firestore
    await _pasosCollection.doc(newId.toString()).set(nuevoPaso.toMap());
  }
}
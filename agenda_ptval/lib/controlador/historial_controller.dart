import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/historial_modelo.dart';

/// Controlador para manejar las operaciones relacionadas con los historiales.
class HistorialController {
  /// Instancia de Firestore para acceder a la colección de historiales.
  final CollectionReference _historialCollection =
      FirebaseFirestore.instance.collection('historiales');

  /// Método para obtener el mayor ID de historial.
  /// 
  /// Devuelve el mayor ID encontrado entre los historiales.
  Future<int> obtenerMayorIdHistorial() async {
    QuerySnapshot snapshot = await _historialCollection.get();
    int maxId = 0;

    for (var doc in snapshot.docs) {
      int currentId = doc['id_historial'] as int;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }

    return maxId;
  }

  /// Método para agregar un nuevo historial.
  /// 
  /// [historial] es la instancia de [Historial] que se va a agregar.
  /// Guarda el historial en la base de datos.
  Future<void> agregarHistorial(Historial historial) async {
    await _historialCollection.add(historial.toJson());
  }

  /// Método para obtener el historial de un estudiante.
  /// 
  /// [idEstudiante] es el ID del estudiante cuyo historial se va a obtener.
  /// Devuelve una instancia de [Historial] si se encuentra, de lo contrario, devuelve null.
  Future<Historial?> obtenerHistorialPorEstudiante(int idEstudiante) async {
    QuerySnapshot snapshot = await _historialCollection.where('id_estudiante', isEqualTo: idEstudiante).get();
    if (snapshot.docs.isNotEmpty) {
      return Historial.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }
}
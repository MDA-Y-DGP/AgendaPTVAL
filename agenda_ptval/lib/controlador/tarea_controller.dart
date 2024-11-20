import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';

class TareaController {
  final CollectionReference _tareasCollection =
      FirebaseFirestore.instance.collection('tareas');
  
  final CollectionReference _estudiantesCollection =
      FirebaseFirestore.instance.collection('estudiantes');

  Future<int> crearTarea(Tarea tarea) async {
    // Obtener todas las tareas para encontrar el mayor ID
    QuerySnapshot querySnapshot = await _tareasCollection.get();
    int maxId = 0;

    for (var doc in querySnapshot.docs) {
      int currentId = doc['idTarea'] as int;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }

    // Asignar a la nueva tarea un ID que sea uno más que el mayor ID encontrado
    int newId = maxId + 1;

    // Crear la nueva tarea con el ID asignado
    Tarea nuevaTarea = Tarea(
      idTarea: newId,
      titulo: tarea.titulo,
      descripcion: tarea.descripcion,
      tipo: tarea.tipo,
      evaluacion: tarea.evaluacion, // Añadir el campo de evaluación
    );

    // Guardar la nueva tarea en Firestore, dejando que Firebase asigne el ID del documento
    await _tareasCollection.add(nuevaTarea.toMap());

    return newId; //Necesario para asignarle el ID a los pasos
  }

  Future<List<Tarea>> obtenerTodasLasTareas() async {
    QuerySnapshot querySnapshot = await _tareasCollection.get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Tarea>> obtenerTareasDeTipoComedor() async {
    QuerySnapshot querySnapshot = await _tareasCollection
        .where('tipo', isEqualTo: 'comedor')
        .get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> asignarTarea(String selectedTarea, String selectedEstudiante) async {
    // Buscar al estudiante por nickname en la colección estudiantes
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: selectedEstudiante)
        .get();

    if (estudianteSnapshot.docs.isNotEmpty) {
      DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
      String estudianteId = estudianteDoc.id;

      // Obtener la fecha de hoy sin la hora
      DateTime now = DateTime.now();
      String fecha = '${now.year}-${now.month}-${now.day}';

      // Referencia a la sub-colección tareas dentro del documento del estudiante
      CollectionReference tareasRef = _estudiantesCollection
          .doc(estudianteId)
          .collection('tareas');

      // Buscar si ya existe un documento con la fecha de hoy
      QuerySnapshot tareasSnapshot = await tareasRef.where('fecha', isEqualTo: fecha).get();

      if (tareasSnapshot.docs.isNotEmpty) {
        // Si ya existe un documento con la fecha de hoy, añadir el ID de la tarea al array id_tareas
        DocumentSnapshot tareaDoc = tareasSnapshot.docs.first;
        List<dynamic> idTareas = List.from(tareaDoc['id_tareas'] ?? []);
        int tareaId = int.parse(selectedTarea);
        if (!idTareas.contains(tareaId)) {
          idTareas.add(tareaId);
          await tareaDoc.reference.update({'id_tareas': idTareas});
        } else {
          throw Exception('La tarea ya está asignada para este día');
        }
      } else {
        // Si no existe un documento con la fecha de hoy, crear uno nuevo
        await tareasRef.add({
          'fecha': fecha,
          'id_tareas': [int.parse(selectedTarea)],
        });
      }
    } else {
      throw Exception('Estudiante no encontrado');
    }
  }

  Future<void> evaluarTarea(int idTarea, String evaluacion) async {
    // Buscar la tarea por ID
    QuerySnapshot querySnapshot = await _tareasCollection.where('idTarea', isEqualTo: idTarea).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot tareaDoc = querySnapshot.docs.first;

      // Actualizar el campo de evaluación de la tarea
      await tareaDoc.reference.update({'evaluacion': evaluacion});
    } else {
      throw Exception('Tarea no encontrada');
    }
  }
}
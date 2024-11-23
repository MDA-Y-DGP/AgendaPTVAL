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
      pasos: tarea.pasos,
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

  Future<List<Tarea>> obtenerTareasDeTipoPorPasos() async {
    QuerySnapshot querySnapshot = await _tareasCollection
        .where('tipo', isEqualTo: 'por pasos')
        .get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Tarea>> obtenerTareasDeTipoInventario() async {
    QuerySnapshot querySnapshot = await _tareasCollection
        .where('tipo', isEqualTo: 'inventario')
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

      // Buscar la tarea en la colección principal de tareas por idTarea
      QuerySnapshot tareaQuerySnapshot = await _tareasCollection
          .where('idTarea', isEqualTo: int.parse(selectedTarea))
          .get();

      if (tareaQuerySnapshot.docs.isEmpty) {
        throw Exception('Tarea no encontrada');
      }

      DocumentSnapshot tareaSnapshot = tareaQuerySnapshot.docs.first;
      Tarea tarea = Tarea.fromMap(tareaSnapshot.data() as Map<String, dynamic>);

      // Referencia a la subcolección tareasAsignadas dentro del documento del estudiante
      CollectionReference tareasAsignadasRef = _estudiantesCollection
          .doc(estudianteId)
          .collection('tareasAsignadas');

      // Añadir la tarea asignada
      await tareasAsignadasRef.add({
        'fecha': fecha,
        'tarea': tarea.toMap(),
      });
    } else {
      throw Exception('Estudiante no encontrado');
    }
  }

  Future<void> completarTarea(int idTarea, String nicknameEstudiante) async {
    // Buscar al estudiante por su nickname
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Referencia a la subcolección tareasAsignadas
    CollectionReference tareasAsignadasRef = _estudiantesCollection
        .doc(estudianteId)
        .collection('tareasAsignadas');

    // Buscar la tarea en la subcolección tareasAsignadas
    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef
        .where('tarea.idTarea', isEqualTo: idTarea)
        .get();

    if (tareasAsignadasSnapshot.docs.isEmpty) {
      throw Exception('Tarea no encontrada en tareas asignadas');
    }

    // Obtener la tarea
    DocumentSnapshot tareaDoc = tareasAsignadasSnapshot.docs.first;
    Map<String, dynamic> tareaData = tareaDoc.data() as Map<String, dynamic>;
    Tarea tarea = Tarea.fromMap(tareaData['tarea']);

    // Referencia a la subcolección tareasCompletadas
    CollectionReference tareasCompletadasRef = _estudiantesCollection
        .doc(estudianteId)
        .collection('tareasCompletadas');

    // Mover la tarea a tareasCompletadas
    await tareasCompletadasRef.add({
      'fecha': DateTime.now().toString(),
      'tarea': tarea.toMap(),
    });

    // Eliminar de tareasAsignadas
    await tareaDoc.reference.delete();
  }


  Future<void> evaluarTarea(int idTarea, String evaluacion, String nicknameEstudiante) async {
    // Buscar al estudiante por su nickname en la colección estudiantes
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    // Obtener el ID del documento del estudiante
    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Referencia a la subcolección de tareas del estudiante
    CollectionReference tareasRef = _estudiantesCollection
        .doc(estudianteId)
        .collection('tareasCompletadas');

    // Obtener todas las tareas de la subcolección
    QuerySnapshot tareasSnapshot = await tareasRef.get();

    if (tareasSnapshot.docs.isEmpty) {
      throw Exception('No hay tareas completadas para este estudiante');
    }

    // Buscar la tarea con el idTarea especificado
    bool tareaEncontrada = false;
    for (var tareaDoc in tareasSnapshot.docs) {
      Map<String, dynamic> data = tareaDoc.data() as Map<String, dynamic>;

      // Acceder al campo 'tarea', que es un mapa
      Map<String, dynamic> tarea = data['tarea'] ?? {};

      // Verificar si el idTarea coincide
      if (tarea['idTarea'] == idTarea) {
        // Actualizar la evaluación de la tarea
        tarea['evaluacion'] = evaluacion;

        // Actualizar el documento con la tarea modificada
        await tareaDoc.reference.update({
          'tarea': tarea, // Actualizamos la tarea en el documento
        });
        tareaEncontrada = true;
        break;
      }
    }

    if (!tareaEncontrada) {
      throw Exception('Tarea con idTarea $idTarea no encontrada en las asignaciones de este estudiante');
    }
  }





  Future<List<Tarea>> obtenerTareasAsignadas(String nicknameEstudiante) async {
    // Buscar al estudiante
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Obtener tareas asignadas
    CollectionReference tareasAsignadasRef = _estudiantesCollection
        .doc(estudianteId)
        .collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef.get();

    // Convertir tareas a objetos Tarea
    List<Tarea> tareasAsignadas = tareasAsignadasSnapshot.docs.map((doc) {
      return Tarea.fromMap(doc['tarea']);
    }).toList();

    return tareasAsignadas;
  }

  Future<List<Tarea>> obtenerTareasCompletadas(String nicknameEstudiante) async {
    // Buscar al estudiante
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Obtener tareas completadas
    CollectionReference tareasCompletadasRef = _estudiantesCollection
        .doc(estudianteId)
        .collection('tareasCompletadas');

    QuerySnapshot tareasCompletadasSnapshot = await tareasCompletadasRef.get();

    // Convertir tareas a objetos Tarea
    List<Tarea> tareasCompletadas = tareasCompletadasSnapshot.docs.map((doc) {
      return Tarea.fromMap(doc['tarea']);
    }).toList();

    return tareasCompletadas;
  }


}
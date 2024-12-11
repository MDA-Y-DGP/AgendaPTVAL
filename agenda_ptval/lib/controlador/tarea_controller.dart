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
      mediaUrls: tarea.mediaUrls,
      imageUrls: tarea.imageUrls,
      videoUrls: tarea.videoUrls,
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
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'comedor').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Tarea>> obtenerTareasDeTipoPorPasos() async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'por pasos').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<List<Tarea>> obtenerTareasDeTipoInventario() async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'inventario').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> asignarTarea(
      String selectedTarea, String nicknameEstudiante, String fecha) async {
    try {
      // Buscar al estudiante
      QuerySnapshot estudianteSnapshot = await _estudiantesCollection
          .where('nickname', isEqualTo: nicknameEstudiante)
          .get();

      if (estudianteSnapshot.docs.isEmpty) {
        throw Exception('Estudiante no encontrado');
      }

      DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
      String estudianteId = estudianteDoc.id;

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

      // Añadir la tarea asignada con el campo completado
      await tareasAsignadasRef.add({
        'fecha': fecha,
        'idTarea': tarea.idTarea,
        'titulo': tarea.titulo,
        'descripcion': tarea.descripcion,
        'tipo': tarea.tipo,
        'pasos': tarea.pasos,
        'evaluacion': tarea.evaluacion,
        'completado': false, // Añadir el campo completado con valor false
      });
    } catch (e) {
      print('Error al asignar tarea: $e');
    }
  }

  Future<void> completarTarea(String idTarea, String nicknameEstudiante) async {
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
        .collection('tareasAsignadas');

    // Buscar la tarea por su ID en Firestore
    DocumentSnapshot tareaDoc = await tareasRef.doc(idTarea.toString()).get();

    // Verificar si la tarea existe
    if (!tareaDoc.exists) {
      throw Exception('Tarea con idTarea $idTarea no encontrada en las asignaciones de este estudiante');
    }

    // Obtener el estado actual de la tarea
    bool completadaActual = tareaDoc['completado'] ?? false; // Si no está definida, asumimos que está incompleta

    // Alternar el estado de completada (de true a false o de false a true)
    bool nuevoEstado = !completadaActual;

    // Actualizar el estado de la tarea en Firestore
    await tareaDoc.reference.update({
      'completado': nuevoEstado, // Alternamos el estado de la tarea
    });
  }

  Future<void> evaluarTarea(
      String idTarea, String evaluacion, String nicknameEstudiante) async {
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
        .collection('tareasAsignadas');

    // Buscar la tarea por su ID en Firestore
    DocumentSnapshot tareaDoc = await tareasRef.doc(idTarea.toString()).get();

    // Verificar si la tarea existe
    if (!tareaDoc.exists) {
      throw Exception('Tarea con idTarea $idTarea no encontrada en las asignaciones de este estudiante');
    }

    // Actualizar la evaluación de la tarea
    await tareaDoc.reference.update({
      'evaluacion': evaluacion, // Actualizamos la evaluación directamente
    });
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

    // Obtener tareas asignadas para ese estudiante
    CollectionReference tareasAsignadasRef =
    _estudiantesCollection.doc(estudianteId).collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef.get();

    // Convertir tareas a objetos Tarea con su id de Firebase
    List<Tarea> tareasAsignadas = tareasAsignadasSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Crear un objeto Tarea con los datos de cada tarea e incluir el id de Firebase
      Tarea tarea = Tarea.fromMap(data);
      tarea.idFirebase = doc.id; // Asignar el id del documento de Firebase

      return tarea;
    }).toList();

    return tareasAsignadas;
  }

  Future<List<Tarea>> obtenerTareasAsignadasPorFecha(String fecha, String nicknameEstudiante) async {
    // Buscar al estudiante
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Obtener tareas asignadas para ese estudiante y fecha
    CollectionReference tareasAsignadasRef =
    _estudiantesCollection.doc(estudianteId).collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef.where('fecha', isEqualTo: fecha).get();

    // Convertir tareas a objetos Tarea con su id de Firebase
    List<Tarea> tareasAsignadas = tareasAsignadasSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Crear un objeto Tarea con los datos de cada tarea e incluir el id de Firebase
      Tarea tarea = Tarea.fromMap(data);
      tarea.idFirebase = doc.id; // Asignar el id del documento de Firebase

      return tarea;
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

    // Obtener tareas asignadas para ese estudiante y fecha
    CollectionReference tareasAsignadasRef =
    _estudiantesCollection.doc(estudianteId).collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef
        .where('completado', isEqualTo: true)
        .get();

    // Convertir tareas a objetos Tarea con su id de Firebase
    List<Tarea> tareasAsignadas = tareasAsignadasSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Crear un objeto Tarea con los datos de cada tarea e incluir el id de Firebase
      Tarea tarea = Tarea.fromMap(data);
      tarea.idFirebase = doc.id; // Asignar el id del documento de Firebase

      return tarea;
    }).toList();

    return tareasAsignadas;
  }

  Future<List<Tarea>> obtenerTareasCompletadasSinEvaluar(String nicknameEstudiante) async {
    // Buscar al estudiante
    QuerySnapshot estudianteSnapshot = await _estudiantesCollection
        .where('nickname', isEqualTo: nicknameEstudiante)
        .get();

    if (estudianteSnapshot.docs.isEmpty) {
      throw Exception('Estudiante no encontrado');
    }

    DocumentSnapshot estudianteDoc = estudianteSnapshot.docs.first;
    String estudianteId = estudianteDoc.id;

    // Obtener tareas asignadas para ese estudiante y fecha
    CollectionReference tareasAsignadasRef =
    _estudiantesCollection.doc(estudianteId).collection('tareasAsignadas');

    QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef
        .where('completado', isEqualTo: true)
        .where('evaluacion', isNull: true)  // Verifica que el campo 'evaluacion' sea null
        .get();

    // Convertir tareas a objetos Tarea con su id de Firebase
    List<Tarea> tareasAsignadas = tareasAsignadasSnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Crear un objeto Tarea con los datos de cada tarea e incluir el id de Firebase
      Tarea tarea = Tarea.fromMap(data);
      tarea.idFirebase = doc.id; // Asignar el id del documento de Firebase

      return tarea;
    }).toList();

    return tareasAsignadas;
  }

  Future<void> borrarTarea(int idTarea) async {
    try {
      // Borrar la tarea de la colección principal
      QuerySnapshot tareaSnapshot =
      await _tareasCollection.where('idTarea', isEqualTo: idTarea).get();

      if (tareaSnapshot.docs.isNotEmpty) {
        await tareaSnapshot.docs.first.reference.delete();
      }

      // Borrar la tarea de la colección tareasAsignadas de los estudiantes
      QuerySnapshot estudiantesSnapshot = await _estudiantesCollection.get();
      for (var estudianteDoc in estudiantesSnapshot.docs) {
        CollectionReference tareasAsignadasRef = _estudiantesCollection
            .doc(estudianteDoc.id)
            .collection('tareasAsignadas');

        QuerySnapshot tareasAsignadasSnapshot = await tareasAsignadasRef
            .where('tarea.idTarea', isEqualTo: idTarea)
            .get();

        for (var tareaAsignadaDoc in tareasAsignadasSnapshot.docs) {
          await tareaAsignadaDoc.reference.delete();
        }
      }
    } catch (e) {
      throw Exception('Error al borrar la tarea: $e');
    }
  }

  // Método para obtener una tarea específica por su ID
  Future<Tarea?> obtenerTareaPorId(int idTarea) async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('idTarea', isEqualTo: idTarea).get();
    if (querySnapshot.docs.isNotEmpty) {
      return Tarea.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null; // Retorna null si no se encuentra la tarea
  }

  // Obtener el texto del paso específico
  String obtenerTextoDePaso(Tarea tarea, int numeroDePaso) {
    if (numeroDePaso < 0 || numeroDePaso >= (tarea.pasos?.length ?? 0)) {
      return 'Paso no disponible'; // Manejo de error si el paso no existe
    }
    return tarea.pasos?[numeroDePaso] ?? ''; // Devuelve el texto del paso
  }

  // Obtener las imágenes del paso específico
  List<String?> obtenerImagenesDePaso(Tarea tarea, int numeroDePaso) {
    if (numeroDePaso < 0 || numeroDePaso >= (tarea.imageUrls?.length ?? 0)) {
      return []; // Manejo de error si las imágenes no están disponibles
    }
    return tarea.imageUrls?[numeroDePaso] ?? [];
  }

  // Obtener los videos del paso específico
  List<String?> obtenerVideosDePaso(Tarea tarea, int numeroDePaso) {
    if (numeroDePaso < 0 || numeroDePaso >= (tarea.videoUrls?.length ?? 0)) {
      return []; // Manejo de error si los videos no están disponibles
    }
    return tarea.videoUrls?[numeroDePaso] ?? [];
  }

  // Obtener media del paso específico
  List<String?> obtenerMediaDePaso(Tarea tarea, int numeroDePaso) {
    if (numeroDePaso < 0 || numeroDePaso >= (tarea.mediaUrls?.length ?? 0)) {
      return []; // Manejo de error si los videos no están disponibles
    }
    return tarea.mediaUrls?[numeroDePaso] ?? [];
  }

}
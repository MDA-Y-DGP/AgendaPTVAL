import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';

/// Controlador para manejar las operaciones relacionadas con las tareas.
class TareaController {
  /// Colección de tareas en Firestore.
  final CollectionReference _tareasCollection =
      FirebaseFirestore.instance.collection('tareas');

  /// Colección de estudiantes en Firestore.
  final CollectionReference _estudiantesCollection =
      FirebaseFirestore.instance.collection('estudiantes');

  /// Método para crear una nueva tarea.
  /// 
  /// [tarea] es la instancia de [Tarea] que se va a crear.
  /// Asigna un nuevo ID a la tarea y la guarda en la base de datos.
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
      materiales: tarea.materiales,
    );

    // Guardar la nueva tarea en Firestore, dejando que Firebase asigne el ID del documento
    await _tareasCollection.add(nuevaTarea.toMap());

    return newId; // Necesario para asignarle el ID a los pasos
  }

  /// Método para obtener todas las tareas.
  /// 
  /// Devuelve una lista de instancias de [Tarea].
  Future<List<Tarea>> obtenerTodasLasTareas() async {
    QuerySnapshot querySnapshot = await _tareasCollection.get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Método para obtener las tareas de tipo "comedor".
  /// 
  /// Devuelve una lista de instancias de [Tarea] de tipo "comedor".
  Future<List<Tarea>> obtenerTareasDeTipoComedor() async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'comedor').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Método para obtener las tareas de tipo "por pasos".
  /// 
  /// Devuelve una lista de instancias de [Tarea] de tipo "por pasos".
  Future<List<Tarea>> obtenerTareasDeTipoPorPasos() async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'por pasos').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Método para obtener las tareas de tipo "inventario".
  /// 
  /// Devuelve una lista de instancias de [Tarea] de tipo "inventario".
  Future<List<Tarea>> obtenerTareasDeTipoInventario() async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('tipo', isEqualTo: 'inventario').get();
    return querySnapshot.docs.map((doc) {
      return Tarea.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  /// Método para asignar una tarea a un estudiante.
  /// 
  /// [selectedTarea] es el ID de la tarea seleccionada.
  /// [nicknameEstudiante] es el nickname del estudiante.
  /// [fecha] es la fecha de asignación de la tarea.
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
        'materiales': tarea.materiales,
        'evaluacion': tarea.evaluacion,
        'completado': false, // Añadir el campo completado con valor false
      });
    } catch (e) {
      print('Error al asignar tarea: $e');
    }
  }

  /// Método para marcar una tarea como completada.
  /// 
  /// [nickname] es el nickname del estudiante.
  /// [idTarea] es el ID de la tarea.
  Future<void> completarTarea(String nickname, int idTarea) async {
    try {
      // Buscar al estudiante por su nickname
      QuerySnapshot estudianteSnapshot = await _estudiantesCollection
          .where('nickname', isEqualTo: nickname)
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
      QuerySnapshot tareaSnapshot = await tareasRef
          .where('idTarea', isEqualTo: idTarea)
          .get();

      // Verificar si la tarea existe
      if (tareaSnapshot.docs.isEmpty) {
        throw Exception('Tarea con idTarea $idTarea no encontrada en las asignaciones de este estudiante');
      }

      // Obtener el documento de la tarea
      DocumentSnapshot tareaDoc = tareaSnapshot.docs.first;

      // Actualizar el campo completado a true
      await tareaDoc.reference.update({'completado': true});
      print('Tarea marcada como completada');
    } catch (e) {
      print('Error al marcar la tarea como completada: $e');
      throw Exception('Error al marcar la tarea como completada: $e');
    }
  }

  /// Método para evaluar una tarea.
  /// 
  /// [idTarea] es el ID de la tarea.
  /// [evaluacion] es la evaluación de la tarea.
  /// [nicknameEstudiante] es el nickname del estudiante.
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

  /// Método para obtener las tareas asignadas a un estudiante.
  /// 
  /// [nicknameEstudiante] es el nickname del estudiante.
  /// Devuelve una lista de instancias de [Tarea].
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

  /// Método para obtener las tareas asignadas a un estudiante por fecha.
  /// 
  /// [fecha] es la fecha de las tareas asignadas.
  /// [nicknameEstudiante] es el nickname del estudiante.
  /// Devuelve una lista de instancias de [Tarea].
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

  /// Método para obtener las tareas completadas por un estudiante.
  /// 
  /// [nicknameEstudiante] es el nickname del estudiante.
  /// Devuelve una lista de instancias de [Tarea] completadas por el estudiante.
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

  /// Método para obtener las tareas completadas por un estudiante que aún no han sido evaluadas.
  /// 
  /// [nicknameEstudiante] es el nickname del estudiante.
  /// Devuelve una lista de instancias de [Tarea] completadas por el estudiante que aún no han sido evaluadas.
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

  /// Método para borrar una tarea.
  /// 
  /// [idTarea] es el ID de la tarea que se quiere borrar.
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

  /// Método para obtener una tarea específica por su ID.
  /// 
  /// [idTarea] es el ID de la tarea.
  /// Devuelve una instancia de [Tarea] si se encuentra, de lo contrario, devuelve null.
  Future<Tarea?> obtenerTareaPorId(int idTarea) async {
    QuerySnapshot querySnapshot =
        await _tareasCollection.where('idTarea', isEqualTo: idTarea).get();
    if (querySnapshot.docs.isNotEmpty) {
      return Tarea.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null; // Retorna null si no se encuentra la tarea
  }

  /// Método para obtener el texto de un paso específico de una tarea.
  /// 
  /// [tarea] es la instancia de [Tarea].
  /// [numeroDePaso] es el número del paso.
  /// Devuelve el texto del paso.
  String obtenerTextoDePaso(Tarea tarea, int numeroDePaso) {
    if (numeroDePaso < 0 || numeroDePaso >= (tarea.pasos?.length ?? 0)) {
      return 'Paso no disponible'; // Manejo de error si el paso no existe
    }
    return tarea.pasos?[numeroDePaso] ?? ''; // Devuelve el texto del paso
  }

  /// Método para modificar una tarea.
  /// 
  /// [tarea] es la instancia de [Tarea] que se va a modificar.
  Future<void> modificarTarea(Tarea tarea) async {
    try {
      QuerySnapshot tareaSnapshot = await _tareasCollection.where('idTarea', isEqualTo: tarea.idTarea).get();
      if (tareaSnapshot.docs.isNotEmpty) {
        await tareaSnapshot.docs.first.reference.update(tarea.toMap());
      }
    } catch (e) {
      throw Exception('Error al modificar la tarea: $e');
    }
  }

  /// Método para obtener los pasos de una tarea.
  /// 
  /// [idTarea] es el ID de la tarea.
  /// Devuelve una lista de mapas con los pasos de la tarea.
  Future<List<Map<String, dynamic>>> obtenerPasos(int idTarea) async {
    try {
      // Obtener la colección de tareas donde idTarea es igual al idTarea proporcionado
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tareas')
          .where('idTarea', isEqualTo: idTarea)
          .get();

      List<Map<String, dynamic>> pasos = [];
      // Verificar si se encontraron documentos en la colección de tareas
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          // Verificar si el documento no es null y contiene el campo lista de pasos
          var data = doc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('pasos')) {
            List<dynamic> pasosList = data['pasos'];
            for (var paso in pasosList) {
              if (paso is Map<String, dynamic>) {
                pasos.add(paso);
              } else if (paso is String) {
                // Manejar el caso en que el paso es un String
                pasos.add({'descripcion': paso});
              } else {
                print('El paso no es del tipo esperado: $paso');
              }
            }
          } else {
            print('El documento no contiene el campo "pasos" o es null');
          }
        }
      } else {
        print('No se encontraron tareas con idTarea: $idTarea');
      }

      print('Pasos obtenidos: $pasos'); // Agrega este print para depurar
      return pasos;
    } catch (e) {
      print('Error al obtener los pasos: $e'); // Agrega este print para depurar
      throw Exception('Error al obtener los pasos: $e');
    }
  }
}
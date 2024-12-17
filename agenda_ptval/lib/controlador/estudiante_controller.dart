import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/estudiante_modelo.dart';
import 'package:agenda_ptval/controlador/historial_controller.dart';
import 'package:agenda_ptval/modelo/historial_modelo.dart';

/// Controlador para manejar las operaciones relacionadas con los estudiantes.
class EstudianteController {
  /// Instancia de Firestore para acceder a la base de datos.
  final CollectionReference _estudiantesCollection =
      FirebaseFirestore.instance.collection('estudiantes');

  /// Instancia del controlador de historial.
  final HistorialController _historialController = HistorialController();

  /// Método para registrar un nuevo estudiante.
  /// 
  /// [estudiante] es la instancia de [Estudiante] que se va a registrar.
  /// Verifica si el nickname ya está en uso, asigna un nuevo ID al estudiante y lo guarda en la base de datos.
  Future<void> registrarEstudiante(Estudiante estudiante) async {
    QuerySnapshot existingNicknames = await _estudiantesCollection
        .where('nickname', isEqualTo: estudiante.nickname)
        .get();

    if (existingNicknames.docs.isNotEmpty) {
      throw Exception('El nickname ya está en uso.');
    }

    QuerySnapshot estudiantesSnapshot = await _estudiantesCollection.get();
    int maxEstudianteId = 0;

    for (var doc in estudiantesSnapshot.docs) {
      int currentId = doc['id_estudiante'] as int;
      if (currentId > maxEstudianteId) {
        maxEstudianteId = currentId;
      }
    }

    int newEstudianteId = maxEstudianteId + 1;
    int maxHistorialId = await _historialController.obtenerMayorIdHistorial();
    int newHistorialId = maxHistorialId + 1;

    Estudiante nuevoEstudiante = Estudiante(
      idEstudiante: newEstudianteId,
      nickname: estudiante.nickname,
      gradoAprendizaje: estudiante.gradoAprendizaje,
      idClase: estudiante.idClase,
      idHistorial: newHistorialId,
      contrasena: estudiante.contrasena,
    );

    Historial nuevoHistorial = Historial(
      idHistorial: newHistorialId,
      idEstudiante: newEstudianteId,
      tareas: {
        'fecha': DateTime.now(),
        'nombre': ['tarea 1'],
      },
    );

    await _estudiantesCollection.add(nuevoEstudiante.toJson());
    await _historialController.agregarHistorial(nuevoHistorial);
  }

  /// Método para iniciar sesión de un estudiante.
  /// 
  /// [nickname] es el nickname del estudiante.
  /// [contrasena] es la contraseña del estudiante.
  /// Devuelve una instancia de [Estudiante] si las credenciales son correctas, de lo contrario, devuelve null.
  Future<Estudiante?> iniciarSesion(String nickname, String contrasena) async {
    try {
      QuerySnapshot query = await _estudiantesCollection
          .where('nickname', isEqualTo: nickname)
          .where('contrasena', isEqualTo: contrasena)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }

      var doc = query.docs.first;
      return Estudiante.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Método para obtener los nombres y grados de aprendizaje de todos los estudiantes.
  /// 
  /// Devuelve una lista de mapas con los campos 'nickname' y 'gradoAprendizaje'.
  Future<List<Map<String, dynamic>>> obtenerNombreGradoDeEstudiantes() async {
    try {
      QuerySnapshot querySnapshot = await _estudiantesCollection.get();

      List<Map<String, dynamic>> listaEstudiantes = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        listaEstudiantes.add({
          'nickname': data['nickname'],
          'gradoAprendizaje': data['grado_aprendizaje']
        });
      }

      return listaEstudiantes;
    } catch (e) {
      throw Exception('Error al obtener nombres y grados de estudiantes: $e');
    }
  }

  /// Método para obtener los estudiantes de una clase específica.
  /// 
  /// [claseId] es el identificador de la clase.
  /// Devuelve una lista de instancias de [Estudiante].
  Future<List<Estudiante>> obtenerEstudiantesPorClase(String claseId) async {
    try {
      int claseIdInt = int.parse(claseId);
      QuerySnapshot snapshot = await _estudiantesCollection
          .where('id_clase', isEqualTo: claseIdInt)
          .get();
      return snapshot.docs
          .map((doc) => Estudiante.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener estudiantes por clase: $e');
    }
  }

  /// Método para obtener el ID de un estudiante por su nickname.
  /// 
  /// [nickname] es el nickname del estudiante.
  /// Devuelve el ID del estudiante como una cadena.
  Future<String?> obtenerIdPorNickname(String nickname) async {
    try {
      QuerySnapshot querySnapshot = await _estudiantesCollection
          .where('nickname', isEqualTo: nickname)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      var doc = querySnapshot.docs.first;
      return doc['id_estudiante'].toString();
    } catch (e) {
      throw Exception('Error al obtener ID del estudiante: $e');
    }
  }

  /// Método para obtener las tareas de un estudiante por su nickname.
  /// 
  /// [nickname] es el nickname del estudiante.
  /// Devuelve una lista de mapas con los campos 'nombre' y 'completada'.
  Future<List<Map<String, dynamic>>> obtenerTareasPorNickname(
      String nickname) async {
    try {
      String? estudianteId = await obtenerIdPorNickname(nickname);
      if (estudianteId == null) {
        return [];
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('historiales')
          .where('idEstudiante', isEqualTo: estudianteId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      var historialDoc = querySnapshot.docs.first;
      var data = historialDoc.data() as Map<String, dynamic>;

      List<Map<String, dynamic>> tareas = [];
      for (var tarea in data['tareas']) {
        tareas.add({
          'nombre': tarea['nombre'],
          'completada': tarea['completada'],
        });
      }

      return tareas;
    } catch (e) {
      throw Exception('Error al obtener tareas del estudiante: $e');
    }
  }

  /// Método para obtener todos los estudiantes.
  /// 
  /// Devuelve una lista de instancias de [Estudiante].
  Future<List<Estudiante>> obtenerTodosEstudiantes() async {
    try {
      QuerySnapshot snapshot = await _estudiantesCollection.get();
      return snapshot.docs
          .map((doc) => Estudiante.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener todos los estudiantes: $e');
    }
  }

  /// Método para eliminar un estudiante.
  /// 
  /// [id] es el identificador único del estudiante que se quiere eliminar.
  Future<void> eliminarEstudiante(String id) async {
    try {
      QuerySnapshot querySnapshot = await _estudiantesCollection
          .where('id_estudiante', isEqualTo: int.parse(id))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar estudiante: $e');
    }
  }

  /// Método para obtener las tareas asignadas a un estudiante por fecha.
  /// 
  /// [fecha] es la fecha de las tareas asignadas.
  /// [nickname] es el nickname del estudiante.
  /// Devuelve una lista de mapas con las tareas asignadas.
  Future<List<Map<String, dynamic>>> obtenerTareasAsignadasPorFecha(
      String fecha, String nickname) async {
    print('Fecha: $fecha, Nickname: $nickname');
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tareasAsignadas')
          .where('fecha', isEqualTo: fecha)
          .where('nickname', isEqualTo: nickname)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> tareas = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        tareas.add(data['tarea']);
      }
      print(tareas);
      return tareas;
    } catch (e) {
      throw Exception(
          'Error al obtener tareas asignadas para la fecha $fecha y nickname $nickname: $e');
    }
  }

  /// Método para modificar el perfil de un estudiante.
  /// 
  /// [id] es el identificador único del estudiante.
  /// [nuevosDatos] es un mapa con los nuevos datos del estudiante.
  Future<void> modificarPerfilEstudiante(
      String id, Map<String, dynamic> nuevosDatos) async {
    try {
      QuerySnapshot querySnapshot = await _estudiantesCollection
          .where('id_estudiante', isEqualTo: int.parse(id))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        await doc.reference.update(nuevosDatos);
      } else {
        throw Exception('No se encontró el estudiante con este ID');
      }
    } catch (e) {
      throw Exception('Error al modificar el perfil del estudiante: $e');
    }
  }
}
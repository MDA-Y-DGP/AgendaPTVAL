import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agenda_ptval/modelo/profesor_modelo.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class ProfesorController {
  final CollectionReference _profesoresCollection =
      FirebaseFirestore.instance.collection('profesores');

  Future<void> registrarProfesor(Profesor profesor) async {
    QuerySnapshot existingNicknames = await _profesoresCollection
        .where('nickname', isEqualTo: profesor.nickname)
        .get();

    if (existingNicknames.docs.isNotEmpty) {
      throw Exception('El nickname ya está en uso.');
    }

    QuerySnapshot querySnapshot = await _profesoresCollection.get();
    int maxId = 0;

    for (var doc in querySnapshot.docs) {
      int currentId = doc['id_profesor'] as int;
      if (currentId > maxId) {
        maxId = currentId;
      }
    }

    int newId = maxId + 1;

    Profesor nuevoProfesor = Profesor(
      idProfesor: newId,
      nickname: profesor.nickname,
      administrador: profesor.administrador,
      contrasena: profesor.contrasena,
    );

    await _profesoresCollection.add(nuevoProfesor.toMap());
  }

  Future<Profesor?> obtenerProfesorPorId(String id) async {
    DocumentSnapshot doc = await _profesoresCollection.doc(id).get();
    if (doc.exists) {
      return Profesor.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Profesor>> obtenerTodosLosProfesores() async {
    QuerySnapshot querySnapshot = await _profesoresCollection.get();
    return querySnapshot.docs
        .map((doc) => Profesor.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Profesor?> verificarCredenciales(
      String nickname, String contrasena) async {
    final QuerySnapshot result = await _profesoresCollection
        .where('nickname', isEqualTo: nickname)
        .get();

    if (result.docs.isNotEmpty) {
      final doc = result.docs.first;
      final profesor = Profesor.fromMap(doc.data() as Map<String, dynamic>);

      String hashedPassword =
          sha256.convert(utf8.encode(contrasena)).toString();
      if (profesor.contrasena == hashedPassword) {
        return profesor;
      }
    }
    return null;
  }

  Future<void> modificarContrasena(String nickname, String nuevaContrasena) async {
    String hashedPassword = _hashPassword(nuevaContrasena);
    QuerySnapshot querySnapshot = await _profesoresCollection
        .where('nickname', isEqualTo: nickname)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = querySnapshot.docs.first;
      await doc.reference.update({'contraseña': hashedPassword});
    } else {
      throw Exception('No se encontró el profesor con este nickname');
    }
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> eliminarProfesor(String id) async {
    try {
      QuerySnapshot querySnapshot = await _profesoresCollection
          .where('id_profesor', isEqualTo: int.parse(id))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
      }
    } catch (e) {
      throw Exception('Error al eliminar profesor: $e');
    }
  }
}
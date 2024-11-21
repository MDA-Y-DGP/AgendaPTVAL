import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ImagenController {
  Future<String> subirImagen(File imagen, String ruta, String nombre) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('$ruta/$nombre.jpg');
      final uploadTask = storageRef.putFile(imagen);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  Future<String> subirImagenWeb(
      Uint8List imagenBytes, String ruta, String nombre) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('$ruta/$nombre.jpg');
      final uploadTask = storageRef.putData(imagenBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  Future<String> subirImagenPaso(
      File imagen, String ruta, String nombre) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$ruta/$nombre');
      final uploadTask = storageRef.putFile(imagen);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  Future<String> subirImagenWebPaso(
      Uint8List imagenBytes, String ruta, String nombre) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$ruta/$nombre');
      final uploadTask = storageRef.putData(imagenBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir la imagen: $e');
    }
  }

  Future<String> obtenerFotoPerfil(String nickname) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('img_perfil/$nickname.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      // Si no se encuentra la foto de perfil, devolver la URL de la imagen por defecto
      final defaultRef =
          FirebaseStorage.instance.ref().child('img_perfil/foto de perfil.png');
      return await defaultRef.getDownloadURL();
    }
  }

  Future<String> obtenerImagenPorNombre(String nombre) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('materiales/$nombre.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      throw Exception('Error al obtener la imagen: $e');
    }
  }
}

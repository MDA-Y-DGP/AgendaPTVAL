import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'tarea_controller.dart';

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

  Future<String> subirVideo(File video, String ruta, String nombre) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$ruta/$nombre');
      final uploadTask = storageRef.putFile(video);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir el video: $e');
    }
  }

  Future<String> subirVideoWeb(Uint8List videoBytes, String ruta, String nombre) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('$ruta/$nombre');
      final uploadTask = storageRef.putData(videoBytes);
      final snapshot = await uploadTask.whenComplete(() => null);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir el video: $e');
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

  Future<String> obtenerFotoMenu(String nombre) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('img_menu/$nombre.png');
      
      print('URL de la imagen: ${await storageRef.getDownloadURL()}');
      return await storageRef.getDownloadURL();
    } catch (e) {
      // Si no se encuentra la foto de perfil, devolver la URL de la imagen por defecto
      final defaultRef =
          FirebaseStorage.instance.ref().child('img_menu/foto_menu.png');
      return await defaultRef.getDownloadURL();
    }
  }

  Future<String> obtenerImagenPaso(int idTarea, int paso) async {
    try {
      // Obtener la tarea a partir del ID usando el TareaController
      final TareaController tareaController = TareaController();
      final tarea = await tareaController.obtenerTareaPorId(idTarea);
      if (tarea == null) {
        throw Exception('Tarea no encontrada');
      }
      final nombreTarea = tarea.titulo;
      print('Nombre de la tarea: $nombreTarea');
  
      // Listar todos los archivos en el directorio de la tarea
      final directoryRef = FirebaseStorage.instance.ref().child('tareas/$nombreTarea');
      final ListResult result = await directoryRef.listAll();
      print('Archivos en el directorio: ${result.items.map((item) => item.name).toList()}');
  
      // Buscar el archivo que comienza con el número de paso seguido de un espacio
      Reference? imageRef;
      for (var item in result.items) {
        if (item.name.startsWith('$paso ')) {
          imageRef = item;
          break;
        }
      }
  
      if (imageRef == null) {
        throw Exception('Imagen del paso no encontrada');
      }
  
      // Obtener la URL de la imagen
      final imageUrl = await imageRef.getDownloadURL();
      print('URL de la imagen obtenida del paso: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('Error al obtener la imagen del paso: $e');
      // Si no se encuentra la imagen del paso, devolver la URL de la imagen por defecto
      final defaultRef = FirebaseStorage.instance.ref().child('tareas/default.jpg');
      return await defaultRef.getDownloadURL();
    }
  }
}


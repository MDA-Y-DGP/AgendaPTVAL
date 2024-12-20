import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importar para inicializar la configuración regional

/// Controlador para manejar las operaciones relacionadas con las comandas.
class ComandaController {
  /// Mapa para almacenar las comandas por clase y tipo de menú.
  final Map<String, Map<String, int>> comandas = {};

  /// Nota adicional para la comanda.
  String? nota;

  /// Lista de nombres de clases.
  List<String> clases = [];

  /// Lista de tipos de menú.
  List<String> tiposMenu = [];

  /// Controlador de página para la navegación entre páginas.
  final PageController pageController = PageController();

  /// Índice de la página actual.
  int paginaActual = 0;

  /// Controlador de texto para la nota.
  final TextEditingController notaController = TextEditingController();

  /// Método para obtener las clases desde Firestore.
  /// 
  /// [callback] es una función que se llama después de obtener las clases.
  Future<void> obtenerClases(Function callback) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('clases').get();
      List<String> clases =
          snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      this.clases = clases;
      for (var clase in clases) {
        comandas[clase] = {};
        for (var tipoMenu in tiposMenu) {
          comandas[clase]![tipoMenu] = 0;
        }
      }
      print('Clases obtenidas: $clases'); // Depuración
      callback(); // Notificar a la interfaz de usuario
    } catch (e) {
      print('Error al obtener clases: $e');
    }
  }

  /// Método para obtener los menús desde Firestore.
  /// 
  /// [callback] es una función que se llama después de obtener los menús.
  Future<void> obtenerMenus(Function callback) async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('menus').get();
      List<String> menus =
          snapshot.docs.map((doc) => doc['nombre'] as String).toList();
      tiposMenu = menus;
      for (var clase in clases) {
        for (var tipoMenu in tiposMenu) {
          comandas[clase]![tipoMenu] = 0;
        }
      }
      print('Menús obtenidos: $menus'); // Depuración
      callback(); // Notificar a la interfaz de usuario
    } catch (e) {
      print('Error al obtener menús: $e');
    }
  }

  /// Método para incrementar la cantidad de un tipo de menú para una clase.
  /// 
  /// [clase] es el nombre de la clase.
  /// [tipoMenu] es el tipo de menú cuya cantidad se incrementará.
  void incrementarCantidad(String clase, String tipoMenu) {
    comandas[clase]![tipoMenu] = comandas[clase]![tipoMenu]! + 1;
  }

  /// Método para decrementar la cantidad de un tipo de menú para una clase.
  /// 
  /// [clase] es el nombre de la clase.
  /// [tipoMenu] es el tipo de menú cuya cantidad se decrementará.
  void decrementarCantidad(String clase, String tipoMenu) {
    if (comandas[clase]![tipoMenu]! > 0) {
      comandas[clase]![tipoMenu] = comandas[clase]![tipoMenu]! - 1;
    }
  }

  /// Método para agregar una nota a la comanda.
  /// 
  /// [nuevaNota] es la nota que se agregará.
  void agregarNota(String nuevaNota) {
    nota = nuevaNota;
  }

   
    Future<void> confirmarComandaPorClase(String nombreClase) async {
      try {
        await initializeDateFormatting('es_ES', null); // Inicializar configuración regional en español
        DateTime now = DateTime.now().toLocal();
        String formattedDate = DateFormat('d MMMM yyyy', 'es_ES').format(now); // Formatear la fecha en español
    
        // Buscar la clase a partir del nombre de la clase
        var clase = comandas.keys.firstWhere((key) => key == nombreClase, orElse: () => '');
    
        if (clase.isEmpty) {
          print('Clase no encontrada: $nombreClase');
          return;
        }
    
        Map<String, dynamic> comandaData = {
          'nota': nota,
          'menus': comandas[clase],
          'hecha': true,
        };
    
        // Buscar un documento existente con la misma fecha
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('comandas')
            .where('fecha', isEqualTo: formattedDate)
            .get();
    
        if (querySnapshot.docs.isNotEmpty) {
          // Si existe un documento con la misma fecha, actualizarlo
          DocumentReference docRef = querySnapshot.docs.first.reference;
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(docRef);
    
            if (snapshot.exists) {
              Map<String, dynamic> existingData = snapshot.data() as Map<String, dynamic>;
              if (existingData['clases'] == null) {
                existingData['clases'] = {};
              }
              existingData['clases'][nombreClase] = comandaData;
              transaction.update(docRef, existingData);
            }
          });
        } else {
          // Si no existe un documento con la misma fecha, crear uno nuevo
          await FirebaseFirestore.instance.collection('comandas').add({
            'fecha': formattedDate,
            'nota': nota,
            'clases': {
              nombreClase: comandaData,
            },
          });
        }
    
        print('Comanda confirmada para la clase $clase: ${comandas[clase]}');
        print('Nota: $nota');
      } catch (e) {
        print('Error al confirmar comanda para la clase $nombreClase: $e');
      }
    }
  /// Método para verificar si la comanda de una clase específica ya está hecha.
    Future<bool> ComprobarComandaClase(String nombreClase) async {
    print("ComprobarComandaClase: $nombreClase");
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('comandas').doc('comanda').get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        var clasesData = data['clases'];
        if (clasesData != null && clasesData is Map) {
          var claseData = clasesData[nombreClase];
          if (claseData != null && claseData is Map) {
            print("ClaseData: $claseData"+" hecha");
            return claseData['hecha'] == true;
            
          }
        }
      }
    } catch (e) {
      print('Error al verificar si la comanda está hecha para la clase $nombreClase: $e');
    }
    return false;
  }
  /// Método para cambiar la página actual en el controlador de página.
  /// 
  /// [index] es el índice de la nueva página.
  void cambiarPagina(int index) {
    paginaActual = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
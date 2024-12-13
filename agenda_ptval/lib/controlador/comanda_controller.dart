import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importar para inicializar la configuración regional

class ComandaController {
  final Map<String, Map<String, int>> comandas = {};
  String? nota;
  List<String> clases = [];
  List<String> tiposMenu = [];
  final PageController pageController = PageController();
  int paginaActual = 0;
  final TextEditingController notaController = TextEditingController();

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

  void incrementarCantidad(String clase, String tipoMenu) {
    comandas[clase]![tipoMenu] = comandas[clase]![tipoMenu]! + 1;
  }

  void decrementarCantidad(String clase, String tipoMenu) {
    if (comandas[clase]![tipoMenu]! > 0) {
      comandas[clase]![tipoMenu] = comandas[clase]![tipoMenu]! - 1;
    }
  }

  void agregarNota(String nuevaNota) {
    nota = nuevaNota;
  }

  Future<void> confirmarComanda() async {
    try {
      await initializeDateFormatting(
          'es_ES', null); // Inicializar configuración regional en español
      DateTime now = DateTime.now().toLocal();
      String formattedDate = DateFormat('d MMMM yyyy', 'es_ES')
          .format(now); // Formatear la fecha en español

      Map<String, dynamic> comandaData = {
        'fecha': formattedDate,
        'nota': nota,
        'clases': comandas.map((clase, menus) {
          return MapEntry(clase, {
            'menus': menus,
          });
        }),
      };

      await FirebaseFirestore.instance.collection('comandas').add(comandaData);
      print('Comanda confirmada: $comandas');
      print('Nota: $nota');
    } catch (e) {
      print('Error al confirmar comanda: $e');
    }
  }

  void cambiarPagina(int index) {
    paginaActual = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
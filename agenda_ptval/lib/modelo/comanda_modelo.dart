import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa una comanda.
class Comanda {
  /// ID de la clase.
  final String idClase;

  /// Fecha de la comanda.
  final DateTime fecha;

  /// Menús de la comanda.
  final Map<String, int> menus;

  /// Constructor de la clase [Comanda].
  Comanda({
    required this.idClase,
    required this.fecha,
    required this.menus,
  });

  /// Método para convertir un objeto [Comanda] a un mapa (JSON).
  Map<String, dynamic> toJson() {
    return {
      'id_clase': idClase,
      'fecha': Timestamp.fromDate(fecha),
      'menus': menus,
    };
  }

  /// Método para crear un objeto [Comanda] desde un mapa (JSON).
  /// 
  /// [json] es el mapa que contiene los datos de la comanda.
  /// Devuelve una instancia de [Comanda].
  factory Comanda.fromJson(Map<String, dynamic> json) {
    return Comanda(
      idClase: json['id_clase'],
      fecha: (json['fecha'] as Timestamp).toDate(),
      menus: Map<String, int>.from(json['menus']),
    );
  }
}
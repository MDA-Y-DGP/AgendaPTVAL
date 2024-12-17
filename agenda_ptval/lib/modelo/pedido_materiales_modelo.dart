import 'package:agenda_ptval/modelo/inventario_modelo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PedidoMateriales {
  /// ID de la clase.
  final String idClase;

  /// Fecha del pedido.
  final DateTime fecha;

  /// Materiales del pedido.
  final List<Inventario> materiales;

  /// Indica si el pedido ha sido visto.
  final bool visto;

  /// Constructor de la clase [PedidoMateriales].
  PedidoMateriales({
    required this.idClase,
    required this.fecha,
    required this.materiales,
    required this.visto,
  });

  /// Método para convertir una instancia de [PedidoMateriales] a un mapa.
  Map<String, dynamic> toMap() {
    return {
      'id_clase': idClase,
      'fecha': Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day)),
      'materiales': materiales.map((material) => material.toMap()).toList(),
      'visto': visto,
    };
  }

  /// Método para crear una instancia de [PedidoMateriales] a partir de un mapa.
  factory PedidoMateriales.fromMap(Map<String, dynamic> map) {
    return PedidoMateriales(
      idClase: map['id_clase'],
      fecha: (map['fecha'] as Timestamp).toDate(),
      materiales: List<Inventario>.from(
        map['materiales']?.map((x) => Inventario.fromMap(x)),
      ),
      visto: map['visto'],
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'inventario_modelo.dart';

class PedidoMateriales {
  final String idClase;
  final DateTime fecha;
  final List<Inventario> materiales;
  final bool visto;

  PedidoMateriales({
    required this.idClase,
    required this.fecha,
    required this.materiales,
    required this.visto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_clase': idClase,
      'fecha': Timestamp.fromDate(DateTime(fecha.year, fecha.month, fecha.day)),
      'materiales': materiales.map((material) => material.toMap()).toList(),
      'visto': visto,
    };
  }

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
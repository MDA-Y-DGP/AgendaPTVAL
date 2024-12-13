import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear las fechas
import 'package:agenda_ptval/modelo/notificacion.dart';
import 'package:agenda_ptval/modelo/tarea_modelo.dart';
import 'package:agenda_ptval/controlador/tarea_controller.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({Key? key}) : super(key: key);

  @override
  _NotificacionesPageState createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final TareaController _tareaController = TareaController();

  // Lista de notificaciones de ejemplo
  List<Notificacion> notificaciones = [
    Notificacion(
      fecha: DateTime(2024, 11, 25, 14, 30),
      idClase: "2",
      profesor: "Profesor 1",
      materiales: {'Gomas': 1, 'Lapices': 3}
    ),
    Notificacion(
      fecha: DateTime(2024, 11, 20, 10, 0),
      idClase: "1",
      profesor: "Profesor 2",
      materiales: {'Gomas': 1, 'Lacpices': 3, 'Cartulinas': 2}
    ),
  ];

  List<Notificacion> get notificacionesOrdenadas {
    // Ordenar primero por si ha sido vista, luego por fecha
    notificaciones.sort((a, b) {
      if (a.vista == b.vista) {
        return b.fecha.compareTo(a.fecha); // Si son iguales, ordenar por fecha
      }
      return a.vista ? 1 : -1; // No vistas arriba
    });
    return notificaciones;
  }

  // Crear tarea a partir de la notificación
  void _crearTarea(Notificacion notificacion) {
    Tarea nuevaTarea = Tarea(
      idTarea: 0,
      titulo: 'Pedir materiales clase ${notificacion.idClase}',
      descripcion: 'Materiales pedidos para la clase: ${notificacion.idClase}',
      tipo: 'inventario',
      materiales: notificacion.materiales,
    );

    // Llamar al controlador de tareas para crear la tarea
    _tareaController.crearTarea(nuevaTarea);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tarea creada para la clase ${notificacion.idClase}')),
    );
  }

  // Mostrar los detalles de la notificación
  void _verDetalles(Notificacion notificacion) {
    if (!notificacion.vista) { // Solo permitir ver detalles si no está vista
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Detalles de la Notificación'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fecha: ${DateFormat.yMd().add_Hm().format(notificacion.fecha)}'),
              Text('Clase: ${notificacion.idClase}'),
              Text('Profesor: ${notificacion.profesor}'),
              const SizedBox(height: 10),
              Text('Materiales pedidos:'),
              ...notificacion.materiales.entries.map((entry) {
                return Text('- ID: ${entry.key} (x${entry.value})');
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                _crearTarea(notificacion);
                Navigator.pop(context);  // Cerrar el diálogo después de crear la tarea
              },
              child: const Text('Crear tarea'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notificacionesOrdenadas.length,
          itemBuilder: (context, index) {
            final notificacion = notificacionesOrdenadas[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(
                  notificacion.vista ? Icons.check_circle : Icons.notifications,
                  color: notificacion.vista ? Colors.green : Colors.orange,
                ),
                title: Text(
                  'Pedido de materiales del profesor ${notificacion.profesor} para la clase ${notificacion.idClase} - ${DateFormat.yMd().add_Hm().format(notificacion.fecha)}',
                  style: TextStyle(
                    fontWeight: notificacion.vista ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                trailing: Checkbox(
                  value: notificacion.vista,
                  onChanged: (bool? value) {
                    setState(() {
                      notificacion.vista = value!;
                    });
                  },
                ),
                onTap: () {
                  if (!notificacion.vista) {
                    _verDetalles(notificacion);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
